package com.feloosy.app.widget

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.app.PendingIntent
import android.widget.RemoteViews
import com.feloosy.app.R
import es.antonborri.home_widget.HomeWidgetPlugin

class FeloosyBalanceWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        appWidgetIds.forEach { id ->
            appWidgetManager.updateAppWidget(id, buildViews(context))
        }
    }

    companion object {
        fun buildViews(context: Context): RemoteViews {
            val prefs = HomeWidgetPlugin.getData(context)
            val accountName = prefs.getString("widget_account_name", "Favorite account") ?: "Favorite account"
            val available = prefs.getString("widget_available_amount", "$0.00") ?: "$0.00"
            val hasAvailableMoney = prefs.getBoolean("widget_has_available_money", true)
            return RemoteViews(context.packageName, R.layout.feloosy_balance_widget).apply {
                setTextViewText(R.id.widget_title, accountName)
                setTextViewText(R.id.widget_amount, available)
                setInt(
                    R.id.widget_info_container,
                    "setBackgroundResource",
                    if (hasAvailableMoney) {
                        R.drawable.widget_info_bubble_positive
                    } else {
                        R.drawable.widget_info_bubble_negative
                    }
                )
                setOnClickPendingIntent(
                    R.id.widget_info_container,
                    PendingIntent.getActivity(
                        context,
                        100,
                        Intent(Intent.ACTION_VIEW, Uri.parse("feloosy:///")),
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                    )
                )
                setOnClickPendingIntent(
                    R.id.widget_plus,
                    PendingIntent.getActivity(
                        context,
                        101,
                        Intent(Intent.ACTION_VIEW, Uri.parse("feloosy:///transactions/add?type=income")),
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                    )
                )
                setOnClickPendingIntent(
                    R.id.widget_minus,
                    PendingIntent.getActivity(
                        context,
                        102,
                        Intent(Intent.ACTION_VIEW, Uri.parse("feloosy:///transactions/add?type=expense")),
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                    )
                )
            }
        }
    }
}
