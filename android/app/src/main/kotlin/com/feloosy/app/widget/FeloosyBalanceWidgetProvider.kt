package com.feloosy.app.widget

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
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
            return RemoteViews(context.packageName, R.layout.feloosy_balance_widget).apply {
                setTextViewText(R.id.widget_title, accountName)
                setTextViewText(R.id.widget_amount, available)
            }
        }
    }
}
