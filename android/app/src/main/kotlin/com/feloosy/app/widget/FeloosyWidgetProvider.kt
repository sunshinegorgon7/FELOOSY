package com.feloosy.app.widget

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Path
import android.graphics.RectF
import android.net.Uri
import android.util.Log
import android.view.View
import android.widget.RemoteViews
import com.feloosy.app.R
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONArray

class FeloosyWidgetProvider : AppWidgetProvider() {

    override fun onReceive(context: Context, intent: Intent) {
        Log.d(TAG, "onReceive action=${intent.action}")
        super.onReceive(context, intent)
    }

    override fun onEnabled(context: Context) {
        Log.i(TAG, "onEnabled: first instance added")
    }

    override fun onDisabled(context: Context) {
        Log.i(TAG, "onDisabled: last instance removed")
    }

    override fun onDeleted(context: Context, appWidgetIds: IntArray) {
        Log.i(TAG, "onDeleted: ids=${appWidgetIds.toList()}")
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        Log.i(TAG, "onUpdate: ids=${appWidgetIds.toList()} pkg=${context.packageName}")
        val views = buildViews(context)
        appWidgetIds.forEach { id ->
            try {
                appWidgetManager.updateAppWidget(id, views)
                Log.i(TAG, "onUpdate: updateAppWidget OK id=$id")
            } catch (e: Exception) {
                Log.e(TAG, "onUpdate: updateAppWidget FAILED id=$id", e)
            }
        }
    }

    companion object {

        private const val TAG = "FeloosyWidget"

        private data class CategoryData(val name: String, val amount: Double, val color: Int)

        fun buildViews(context: Context): RemoteViews {
            return try {
                buildViewsInternal(context).also {
                    Log.d(TAG, "buildViews: built successfully")
                }
            } catch (e: Exception) {
                Log.e(TAG, "buildViews: exception — returning bare fallback layout", e)
                RemoteViews(context.packageName, R.layout.feloosy_widget)
            }
        }

        private fun buildViewsInternal(context: Context): RemoteViews {
            val prefs = HomeWidgetPlugin.getData(context)
            val accountName = prefs.getString("fw_account_name", "Wallet") ?: "Wallet"
            val currencyCode = prefs.getString("fw_currency_code", "AED") ?: "AED"
            val availableStr = prefs.getString("fw_available", "0") ?: "0"
            val isOverBudget = prefs.getBoolean("fw_is_over_budget", false)
            val todayEmpty = prefs.getBoolean("fw_today_empty", true)
            val categoriesJson = prefs.getString("fw_categories_json", "[]") ?: "[]"
            val todayTotalStr = prefs.getString("fw_today_total", "0") ?: "0"

            val availableVal = availableStr.toDoubleOrNull() ?: 0.0
            val todayTotal = todayTotalStr.toDoubleOrNull() ?: 0.0
            val categories = parseCategories(categoriesJson)

            val views = RemoteViews(context.packageName, R.layout.feloosy_widget)

            // ── Label ──────────────────────────────────────────────────────
            views.setTextViewText(
                R.id.fw_label,
                if (isOverBudget) "OVER BUDGET" else "AVAILABLE TO SPEND",
            )
            views.setTextColor(
                R.id.fw_label,
                if (isOverBudget) Color.parseColor("#f5a623") else Color.parseColor("#7fa890"),
            )

            // ── Amount ─────────────────────────────────────────────────────
            val displayAmt = if (isOverBudget) {
                "−" + formatAmount(Math.abs(availableVal))
            } else {
                formatAmount(Math.abs(availableVal))
            }
            views.setTextViewText(R.id.fw_amount, displayAmt)
            views.setTextColor(
                R.id.fw_amount,
                if (isOverBudget) Color.parseColor("#f5a623") else Color.parseColor("#f6f1e3"),
            )
            views.setTextViewText(R.id.fw_currency, " $currencyCode")

            // ── Accessibility ──────────────────────────────────────────────
            val availableDesc = "$displayAmt $currencyCode available to spend this month"
            views.setContentDescription(R.id.fw_header_left, availableDesc)
            val barDesc = "This month’s spending: ${formatAmount(todayTotal)} $currencyCode" +
                " across ${categories.size} categories"
            views.setContentDescription(R.id.fw_bar, barDesc)

            // ── Tap root → home screen ─────────────────────────────────────
            val homeIntent = PendingIntent.getActivity(
                context,
                0,
                Intent(Intent.ACTION_VIEW, Uri.parse("feloosy:///")),
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            views.setOnClickPendingIntent(R.id.fw_root, homeIntent)

            // ── Tap − button → add expense ─────────────────────────────────
            val addIntent = PendingIntent.getActivity(
                context,
                1,
                Intent(
                    Intent.ACTION_VIEW,
                    Uri.parse("feloosy:///transactions/add?type=expense"),
                ),
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            views.setOnClickPendingIntent(R.id.fw_add_btn, addIntent)

            // ── Progress bar + legend (hidden when no today spending) ─────────
            if (todayEmpty || categories.isEmpty()) {
                views.setViewVisibility(R.id.fw_bar, View.GONE)
                views.setViewVisibility(R.id.fw_legend, View.GONE)
                views.setViewVisibility(R.id.fw_empty_text, View.GONE)
            } else {
                val barBitmap = buildBarBitmap(categories, categories.sumOf { it.amount })
                views.setImageViewBitmap(R.id.fw_bar, barBitmap)
                views.setViewVisibility(R.id.fw_bar, View.VISIBLE)
                views.setViewVisibility(R.id.fw_legend, View.VISIBLE)
                views.setViewVisibility(R.id.fw_empty_text, View.GONE)
                bindLegend(context, views, categories)
            }

            return views
        }

        // ── Bitmaps ────────────────────────────────────────────────────────

        private fun buildBarBitmap(
            categories: List<CategoryData>,
            total: Double,
        ): Bitmap {
            val w = 240
            val h = 16
            val bmp = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)
            val canvas = Canvas(bmp)
            val paint = Paint(Paint.ANTI_ALIAS_FLAG)

            if (total <= 0.0) return bmp

            val path = Path()
            path.addRoundRect(
                RectF(0f, 0f, w.toFloat(), h.toFloat()),
                8f, 8f,
                Path.Direction.CW,
            )
            canvas.clipPath(path)

            var x = 0f
            for (cat in categories) {
                val segW = (cat.amount / total * w).toFloat()
                paint.color = cat.color
                canvas.drawRect(x, 0f, x + segW, h.toFloat(), paint)
                x += segW
            }
            return bmp
        }

        private fun buildDotBitmap(color: Int): Bitmap {
            val size = 24
            val bmp = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
            val canvas = Canvas(bmp)
            val paint = Paint(Paint.ANTI_ALIAS_FLAG)
            paint.color = color
            canvas.drawCircle(12f, 12f, 12f, paint)
            return bmp
        }

        // ── Legend binding ─────────────────────────────────────────────────

        private fun bindLegend(
            context: Context,
            views: RemoteViews,
            categories: List<CategoryData>,
        ) {
            val slots = listOf(
                Triple(R.id.fw_item_1, R.id.fw_dot_1, R.id.fw_label_1),
                Triple(R.id.fw_item_2, R.id.fw_dot_2, R.id.fw_label_2),
                Triple(R.id.fw_item_3, R.id.fw_dot_3, R.id.fw_label_3),
                Triple(R.id.fw_item_4, R.id.fw_dot_4, R.id.fw_label_4),
            )
            slots.forEachIndexed { i, (itemId, dotId, labelId) ->
                if (i < categories.size) {
                    views.setViewVisibility(itemId, View.VISIBLE)
                    views.setImageViewBitmap(dotId, buildDotBitmap(categories[i].color))
                    views.setTextViewText(labelId, categories[i].name)
                } else {
                    views.setViewVisibility(itemId, View.GONE)
                }
            }
        }

        // ── Helpers ────────────────────────────────────────────────────────

        private fun parseCategories(json: String): List<CategoryData> {
            return try {
                val arr = JSONArray(json)
                (0 until arr.length()).map { i ->
                    val obj = arr.getJSONObject(i)
                    CategoryData(
                        name = obj.getString("name"),
                        amount = obj.getDouble("amount"),
                        color = Color.parseColor(obj.getString("color")),
                    )
                }
            } catch (e: Exception) {
                emptyList()
            }
        }

        private fun formatAmount(amount: Double): String {
            val long = amount.toLong()
            return if (amount == long.toDouble()) "$long"
            else "%.2f".format(amount)
        }
    }
}
