package com.feloosy.app.widget

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
import android.app.PendingIntent
import android.view.View
import android.widget.RemoteViews
import com.feloosy.app.R
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONArray

class FeloosyTodayWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        appWidgetIds.forEach { id ->
            appWidgetManager.updateAppWidget(id, buildViews(context))
        }
    }

    companion object {

        private data class CategoryData(val name: String, val amount: Double, val color: Int)

        fun buildViews(context: Context): RemoteViews {
            return try {
                buildViewsInternal(context)
            } catch (e: Exception) {
                RemoteViews(context.packageName, R.layout.feloosy_today_widget)
            }
        }

        private fun buildViewsInternal(context: Context): RemoteViews {
            val prefs = HomeWidgetPlugin.getData(context)
            val accountName = prefs.getString("widget_spend_account_name", "Wallet") ?: "Wallet"
            val totalStr = prefs.getString("widget_spend_available", "0") ?: "0"
            val categoriesJson = prefs.getString("widget_spend_categories_json", "[]") ?: "[]"
            val isEmpty = prefs.getBoolean("widget_spend_is_empty", true)
            val currencyCode = prefs.getString("widget_spend_currency_code", "AED") ?: "AED"

            val available = totalStr.toDoubleOrNull() ?: 0.0
            val categories = parseCategories(categoriesJson)

            val views = RemoteViews(context.packageName, R.layout.feloosy_today_widget)

            views.setTextViewText(R.id.widget_today_account_label, accountName.uppercase())
            views.setTextViewText(R.id.widget_today_total, formatAmount(available))
            views.setTextViewText(R.id.widget_today_currency, " $currencyCode")

            // Tap root → open home screen
            val homeIntent = PendingIntent.getActivity(
                context,
                200,
                Intent(Intent.ACTION_VIEW, Uri.parse("feloosy:///")),
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            views.setOnClickPendingIntent(R.id.widget_today_root, homeIntent)

            // CTA → new expense screen
            val addIntent = PendingIntent.getActivity(
                context,
                201,
                Intent(
                    Intent.ACTION_VIEW,
                    Uri.parse("feloosy:///transactions/add?type=expense"),
                ),
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            views.setOnClickPendingIntent(R.id.widget_today_add_btn, addIntent)

            // Progress bar bitmap (total expenses as denominator, not available)
            val totalExpenses = categories.sumOf { it.amount }
            val progressBitmap = drawProgressBar(context, categories, totalExpenses, isEmpty)
            views.setImageViewBitmap(R.id.widget_today_progress_bar, progressBitmap)

            if (isEmpty || categories.isEmpty()) {
                views.setViewVisibility(R.id.widget_today_legend, View.GONE)
                views.setViewVisibility(R.id.widget_today_empty_text, View.VISIBLE)
            } else {
                views.setViewVisibility(R.id.widget_today_legend, View.VISIBLE)
                views.setViewVisibility(R.id.widget_today_empty_text, View.GONE)
                bindLegendItems(context, views, categories)
            }

            return views
        }

        private fun parseCategories(json: String): List<CategoryData> {
            return try {
                val arr = JSONArray(json)
                (0 until arr.length()).map { i ->
                    val obj = arr.getJSONObject(i)
                    CategoryData(
                        name = obj.getString("name"),
                        amount = obj.getDouble("amount"),
                        color = parseHexColor(obj.getString("color")),
                    )
                }
            } catch (e: Exception) {
                emptyList()
            }
        }

        private fun parseHexColor(hex: String): Int {
            return try {
                Color.parseColor(hex)
            } catch (e: Exception) {
                Color.argb(102, 246, 241, 227)
            }
        }

        private fun formatAmount(amount: Double): String {
            val long = amount.toLong()
            return if (amount == long.toDouble()) long.toString()
            else String.format("%.2f", amount)
        }

        private fun drawProgressBar(
            context: Context,
            categories: List<CategoryData>,
            total: Double,
            isEmpty: Boolean,
        ): Bitmap {
            val density = context.resources.displayMetrics.density
            val heightPx = (5 * density).toInt().coerceAtLeast(3)
            val widthPx = (360 * density).toInt().coerceAtLeast(200)

            val bitmap = Bitmap.createBitmap(widthPx, heightPx, Bitmap.Config.ARGB_8888)
            val canvas = Canvas(bitmap)
            val paint = Paint(Paint.ANTI_ALIAS_FLAG)

            if (isEmpty || total <= 0.0 || categories.isEmpty()) {
                paint.color = Color.argb(26, 246, 241, 227)
                val lineH = density.coerceAtLeast(1f)
                val top = (heightPx - lineH) / 2f
                canvas.drawRect(0f, top, widthPx.toFloat(), top + lineH, paint)
            } else {
                val cornerPx = (heightPx / 2f)
                val clipPath = Path()
                clipPath.addRoundRect(
                    RectF(0f, 0f, widthPx.toFloat(), heightPx.toFloat()),
                    cornerPx,
                    cornerPx,
                    Path.Direction.CW,
                )
                canvas.clipPath(clipPath)

                var x = 0f
                for (cat in categories) {
                    val segW = (cat.amount / total * widthPx).toFloat()
                    paint.color = cat.color
                    canvas.drawRect(x, 0f, x + segW, heightPx.toFloat(), paint)
                    x += segW
                }
            }

            return bitmap
        }

        private fun createDotBitmap(context: Context, color: Int): Bitmap {
            val density = context.resources.displayMetrics.density
            val sizePx = (5 * density).toInt().coerceAtLeast(5)
            val bitmap = Bitmap.createBitmap(sizePx, sizePx, Bitmap.Config.ARGB_8888)
            val canvas = Canvas(bitmap)
            val paint = Paint(Paint.ANTI_ALIAS_FLAG)
            paint.color = color
            canvas.drawCircle(sizePx / 2f, sizePx / 2f, sizePx / 2f, paint)
            return bitmap
        }

        private fun bindLegendItems(
            context: Context,
            views: RemoteViews,
            categories: List<CategoryData>,
        ) {
            val slots = listOf(
                Triple(R.id.widget_legend_item_1, R.id.widget_legend_dot_1, R.id.widget_legend_label_1),
                Triple(R.id.widget_legend_item_2, R.id.widget_legend_dot_2, R.id.widget_legend_label_2),
                Triple(R.id.widget_legend_item_3, R.id.widget_legend_dot_3, R.id.widget_legend_label_3),
                Triple(R.id.widget_legend_item_4, R.id.widget_legend_dot_4, R.id.widget_legend_label_4),
            )

            slots.forEachIndexed { i, (itemId, dotId, labelId) ->
                if (i < categories.size) {
                    val cat = categories[i]
                    views.setViewVisibility(itemId, View.VISIBLE)
                    views.setImageViewBitmap(dotId, createDotBitmap(context, cat.color))
                    views.setTextViewText(labelId, cat.name)
                } else {
                    views.setViewVisibility(itemId, View.GONE)
                }
            }
        }
    }
}
