package com.example.flutter_ai

import android.annotation.SuppressLint
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.util.DisplayMetrics
import android.util.TypedValue
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.*
import androidx.core.app.NotificationCompat

class FloatingOverlayService : Service() {

    companion object {
        const val CHANNEL_ID = "neuropocket_overlay_channel"
        const val NOTIFICATION_ID = 1001
        var isRunning = false
    }

    private var windowManager: WindowManager? = null
    private var floatingLensView: View? = null
    private var floatingCardView: View? = null
    private var lensParams: WindowManager.LayoutParams? = null
    private var cardParams: WindowManager.LayoutParams? = null

    private val mainHandler = Handler(Looper.getMainLooper())

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        isRunning = true
        startForegroundServiceWithNotification()
        windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
        createFloatingLensWidget()
    }

    private fun startForegroundServiceWithNotification() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "NeuroPocket Floating Lens",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Shows floating on-screen translation lens over other apps"
                setShowBadge(false)
            }
            val manager = getSystemService(NotificationManager::class.java)
            manager?.createNotificationChannel(channel)
        }

        val launchIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        val pendingIntent = PendingIntent.getActivity(
            this, 0, launchIntent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        val notification: Notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("NeuroPocket Floating Lens")
            .setContentText("Active across all apps • Drag to translate")
            .setSmallIcon(android.R.drawable.ic_menu_search)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .build()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startForeground(
                NOTIFICATION_ID,
                notification,
                android.content.pm.ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE
            )
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(
                NOTIFICATION_ID,
                notification,
                android.content.pm.ServiceInfo.FOREGROUND_SERVICE_TYPE_NONE
            )
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
    }

    private fun getOverlayLayoutType(): Int {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        } else {
            @Suppress("DEPRECATION")
            WindowManager.LayoutParams.TYPE_PHONE
        }
    }

    @SuppressLint("ClickableViewAccessibility")
    private fun createFloatingLensWidget() {
        val density = resources.displayMetrics.density
        val bubbleSizePx = (58 * density).toInt()

        lensParams = WindowManager.LayoutParams(
            bubbleSizePx,
            bubbleSizePx,
            getOverlayLayoutType(),
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = 20
            y = (resources.displayMetrics.heightPixels * 0.4).toInt()
        }

        val rootLayout = RelativeLayout(this).apply {
            val gradient = GradientDrawable(
                GradientDrawable.Orientation.TL_BR,
                intArrayOf(Color.parseColor("#0072FF"), Color.parseColor("#00C6FF"))
            ).apply {
                shape = GradientDrawable.OVAL
                setStroke((2.5f * density).toInt(), Color.WHITE)
            }
            background = gradient
            elevation = 16f * density
        }

        // Inner Glass
        val innerCircle = View(this).apply {
            val innerBg = GradientDrawable().apply {
                shape = GradientDrawable.OVAL
                setColor(Color.parseColor("#33FFFFFF"))
                setStroke((1.5f * density).toInt(), Color.parseColor("#80FFFFFF"))
            }
            background = innerBg
        }
        val innerParams = RelativeLayout.LayoutParams(
            (42 * density).toInt(),
            (42 * density).toInt()
        ).apply {
            addRule(RelativeLayout.CENTER_IN_PARENT, RelativeLayout.TRUE)
        }
        rootLayout.addView(innerCircle, innerParams)

        // Magnifying Search Icon
        val iconView = ImageView(this).apply {
            setImageResource(android.R.drawable.ic_menu_search)
            setColorFilter(Color.WHITE)
        }
        val iconParams = RelativeLayout.LayoutParams(
            (28 * density).toInt(),
            (28 * density).toInt()
        ).apply {
            addRule(RelativeLayout.CENTER_IN_PARENT, RelativeLayout.TRUE)
        }
        rootLayout.addView(iconView, iconParams)

        // Yellow Target Crosshair Dot
        val dotView = View(this).apply {
            val dotBg = GradientDrawable().apply {
                shape = GradientDrawable.OVAL
                setColor(Color.parseColor("#FFD700"))
            }
            background = dotBg
        }
        val dotParams = RelativeLayout.LayoutParams(
            (7 * density).toInt(),
            (7 * density).toInt()
        ).apply {
            addRule(RelativeLayout.ALIGN_PARENT_BOTTOM, RelativeLayout.TRUE)
            addRule(RelativeLayout.ALIGN_PARENT_END, RelativeLayout.TRUE)
            bottomMargin = (10 * density).toInt()
            rightMargin = (10 * density).toInt()
        }
        rootLayout.addView(dotView, dotParams)

        // Touch & Drag Handling with Real-time Screen Scanning
        rootLayout.setOnTouchListener(object : View.OnTouchListener {
            private var initialX = 0
            private var initialY = 0
            private var initialTouchX = 0f
            private var initialTouchY = 0f
            private var isClick = false

            override fun onTouch(v: View, event: MotionEvent): Boolean {
                when (event.action) {
                    MotionEvent.ACTION_DOWN -> {
                        initialX = lensParams!!.x
                        initialY = lensParams!!.y
                        initialTouchX = event.rawX
                        initialTouchY = event.rawY
                        isClick = true
                        return true
                    }
                    MotionEvent.ACTION_MOVE -> {
                        val dx = (event.rawX - initialTouchX).toInt()
                        val dy = (event.rawY - initialTouchY).toInt()
                        if (Math.abs(dx) > 10 || Math.abs(dy) > 10) {
                            isClick = false
                        }
                        lensParams!!.x = initialX + dx
                        lensParams!!.y = initialY + dy
                        windowManager?.updateViewLayout(floatingLensView, lensParams)
                        return true
                    }
                    MotionEvent.ACTION_UP -> {
                        val currentX = lensParams!!.x + bubbleSizePx / 2
                        val currentY = lensParams!!.y + bubbleSizePx / 2

                        // Scan on-screen text under lens coordinates using Accessibility Service
                        val scannedText = NeuroAccessibilityService.instance?.findTextAt(currentX, currentY)

                        if (isClick) {
                            if (!scannedText.isNullOrBlank()) {
                                showFloatingTranslationCard(scannedText, lensParams!!.x, lensParams!!.y)
                            } else {
                                val intent = Intent(this@FloatingOverlayService, MainActivity::class.java).apply {
                                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
                                    putExtra("trigger_quick_translate", true)
                                }
                                startActivity(intent)
                            }
                        } else {
                            if (!scannedText.isNullOrBlank()) {
                                showFloatingTranslationCard(scannedText, lensParams!!.x, lensParams!!.y)
                            }

                            // Snap to nearest screen edge
                            val metrics = DisplayMetrics()
                            windowManager?.defaultDisplay?.getMetrics(metrics)
                            val screenWidth = metrics.widthPixels
                            val snapX = if (lensParams!!.x + bubbleSizePx / 2 < screenWidth / 2) 20 else screenWidth - bubbleSizePx - 20
                            lensParams!!.x = snapX
                            windowManager?.updateViewLayout(floatingLensView, lensParams)
                        }
                        return true
                    }
                }
                return false
            }
        })

        floatingLensView = rootLayout
        try {
            windowManager?.addView(floatingLensView, lensParams)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    /**
     * Shows a lightweight Floating Translation Card directly on top of the host app
     */
    @SuppressLint("SetTextI18n")
    private fun showFloatingTranslationCard(originalText: String, lensX: Int, lensY: Int) {
        dismissFloatingTranslationCard()

        val density = resources.displayMetrics.density
        val metrics = DisplayMetrics()
        windowManager?.defaultDisplay?.getMetrics(metrics)

        val cardWidthPx = (300 * density).toInt()
        val cardHeightPx = WindowManager.LayoutParams.WRAP_CONTENT

        var cardX = (lensX - (cardWidthPx / 4)).coerceIn(20, metrics.widthPixels - cardWidthPx - 20)
        var cardY = (lensY + (70 * density).toInt()).coerceIn(60, metrics.heightPixels - (280 * density).toInt())

        cardParams = WindowManager.LayoutParams(
            cardWidthPx,
            cardHeightPx,
            getOverlayLayoutType(),
            WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = cardX
            y = cardY
        }

        val cardLayout = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            val bg = GradientDrawable().apply {
                shape = GradientDrawable.RECTANGLE
                cornerRadius = 16f * density
                setColor(Color.parseColor("#F8FAFC"))
                setStroke((1.5f * density).toInt(), Color.parseColor("#0072FF"))
            }
            background = bg
            setPadding((14 * density).toInt(), (12 * density).toInt(), (14 * density).toInt(), (12 * density).toInt())
            elevation = 20f * density
        }

        // Header Row (NeuroPocket Lens • Close)
        val headerRow = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
        }

        val titleTv = TextView(this).apply {
            text = "NeuroPocket Quick Translate"
            setTextColor(Color.parseColor("#0072FF"))
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 12f)
            setTypeface(null, android.graphics.Typeface.BOLD)
        }
        headerRow.addView(titleTv, LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f))

        val closeBtn = TextView(this).apply {
            text = "✕"
            setTextColor(Color.parseColor("#64748B"))
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f)
            setPadding((6 * density).toInt(), (2 * density).toInt(), (6 * density).toInt(), (2 * density).toInt())
            setOnClickListener { dismissFloatingTranslationCard() }
        }
        headerRow.addView(closeBtn)
        cardLayout.addView(headerRow)

        // Original Scanned Text
        val originalTv = TextView(this).apply {
            text = originalText
            setTextColor(Color.parseColor("#334155"))
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 13f)
            maxLines = 3
            setPadding(0, (6 * density).toInt(), 0, (6 * density).toInt())
        }
        cardLayout.addView(originalTv)

        // Translated Text Box
        val isBangla = originalText.any { it in '\u0980'..'\u09FF' }
        val targetLangLabel = if (isBangla) "English Translation" else "বাংলা অনুবাদ"

        val labelTv = TextView(this).apply {
            text = targetLangLabel
            setTextColor(Color.parseColor("#0D9488"))
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 11f)
            setTypeface(null, android.graphics.Typeface.BOLD)
        }
        cardLayout.addView(labelTv)

        val translatedTv = TextView(this).apply {
            // Quick Instant Preview
            text = if (isBangla) {
                "Translating: $originalText"
            } else {
                "অনুবাদ হচ্ছে: $originalText"
            }
            setTextColor(Color.parseColor("#0F172A"))
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 13.5f)
            setTypeface(null, android.graphics.Typeface.BOLD)
            setPadding(0, (4 * density).toInt(), 0, (8 * density).toInt())
        }
        cardLayout.addView(translatedTv)

        // Action Buttons Row (Copy • Open App)
        val actionsRow = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.END
        }

        val copyBtn = Button(this).apply {
            text = "Copy"
            setTextColor(Color.WHITE)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 11f)
            val btnBg = GradientDrawable().apply {
                cornerRadius = 8f * density
                setColor(Color.parseColor("#0072FF"))
            }
            background = btnBg
            setPadding((10 * density).toInt(), 0, (10 * density).toInt(), 0)
            setOnClickListener {
                val clipboard = getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
                val clip = ClipData.newPlainText("NeuroPocket Translation", translatedTv.text.toString())
                clipboard.setPrimaryClip(clip)
                Toast.makeText(this@FloatingOverlayService, "Copied!", Toast.LENGTH_SHORT).show()
                dismissFloatingTranslationCard()
            }
        }
        val copyParams = LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.WRAP_CONTENT,
            (32 * density).toInt()
        ).apply {
            rightMargin = (8 * density).toInt()
        }
        actionsRow.addView(copyBtn, copyParams)

        val openAppBtn = Button(this).apply {
            text = "Open App"
            setTextColor(Color.parseColor("#0072FF"))
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 11f)
            val btnBg = GradientDrawable().apply {
                cornerRadius = 8f * density
                setColor(Color.parseColor("#E0E7FF"))
            }
            background = btnBg
            setPadding((10 * density).toInt(), 0, (10 * density).toInt(), 0)
            setOnClickListener {
                val intent = Intent(this@FloatingOverlayService, MainActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
                    putExtra("initial_text", originalText)
                    putExtra("trigger_quick_translate", true)
                }
                startActivity(intent)
                dismissFloatingTranslationCard()
            }
        }
        val openParams = LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.WRAP_CONTENT,
            (32 * density).toInt()
        )
        actionsRow.addView(openAppBtn, openParams)

        cardLayout.addView(actionsRow)

        floatingCardView = cardLayout
        try {
            windowManager?.addView(floatingCardView, cardParams)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun dismissFloatingTranslationCard() {
        if (floatingCardView != null && windowManager != null) {
            try {
                windowManager?.removeView(floatingCardView)
            } catch (e: Exception) {
                e.printStackTrace()
            }
            floatingCardView = null
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        isRunning = false
        dismissFloatingTranslationCard()
        if (floatingLensView != null && windowManager != null) {
            try {
                windowManager?.removeView(floatingLensView)
            } catch (e: Exception) {
                e.printStackTrace()
            }
            floatingLensView = null
        }
    }
}
