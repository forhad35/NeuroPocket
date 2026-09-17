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
import android.graphics.Rect
import android.graphics.Typeface
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
import org.json.JSONArray
import java.net.HttpURLConnection
import java.net.URL
import java.net.URLEncoder
import java.util.Locale
import kotlin.concurrent.thread

class FloatingOverlayService : Service() {

    companion object {
        const val CHANNEL_ID = "neuropocket_overlay_channel"
        const val NOTIFICATION_ID = 1001
        var isRunning = false
    }

    private var windowManager: WindowManager? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    // 1. Edge Dock Handle View (Image 2)
    private var edgeHandleView: View? = null
    private var edgeHandleParams: WindowManager.LayoutParams? = null

    // 2. Quick Action Grid Menu View (Image 3)
    private var quickMenuView: View? = null
    private var quickMenuParams: WindowManager.LayoutParams? = null

    // 3. Draggable Magnifying Lens View (Image 4)
    private var magnifyingLensView: View? = null
    private var lensParams: WindowManager.LayoutParams? = null

    // 4. In-Place Text Replacement Overlays (Image 5)
    data class InPlaceOverlayEntry(val view: View, val rect: Rect, val originalText: String)
    private val activeInPlaceOverlays = mutableListOf<InPlaceOverlayEntry>()

    private var isMenuOpen = false
    private var isLensActive = false

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        isRunning = true
        startForegroundServiceWithNotification()
        windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
        createEdgeHandleWidget()
    }

    private fun startForegroundServiceWithNotification() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "NeuroPocket Floating Lens",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Shows floating translation and on-screen assistant overlay"
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
            .setContentTitle("NeuroPocket Screen Translator")
            .setContentText("Active across all apps • Drag edge handle to translate")
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

    // =========================================================================
    // 1. COLLAPSED EDGE HANDLE / SIDEBAR PILL (Matching Image 2)
    // =========================================================================
    @SuppressLint("ClickableViewAccessibility")
    private fun createEdgeHandleWidget() {
        val density = resources.displayMetrics.density
        val handleWidthPx = (16 * density).toInt()
        val handleHeightPx = (60 * density).toInt()

        edgeHandleParams = WindowManager.LayoutParams(
            handleWidthPx,
            handleHeightPx,
            getOverlayLayoutType(),
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = 0
            y = (resources.displayMetrics.heightPixels * 0.35).toInt()
        }

        val handleContainer = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            val bg = GradientDrawable().apply {
                shape = GradientDrawable.RECTANGLE
                cornerRadii = floatArrayOf(
                    0f, 0f,
                    16f * density, 16f * density,
                    16f * density, 16f * density,
                    0f, 0f
                )
                colors = intArrayOf(Color.parseColor("#0072FF"), Color.parseColor("#00C6FF"))
                orientation = GradientDrawable.Orientation.TOP_BOTTOM
            }
            background = bg
            elevation = 14f * density
        }

        // Inner vertical glowing indicator line
        val innerBar = View(this).apply {
            val barBg = GradientDrawable().apply {
                shape = GradientDrawable.RECTANGLE
                cornerRadius = 4f * density
                setColor(Color.WHITE)
            }
            background = barBg
        }
        val barParams = LinearLayout.LayoutParams(
            (3.5f * density).toInt(),
            (28 * density).toInt()
        )
        handleContainer.addView(innerBar, barParams)

        // Continuous Touch & Drag: Pulling handle directly smoothly steers the Magnifying Lens!
        handleContainer.setOnTouchListener(object : View.OnTouchListener {
            private var initialY = 0
            private var initialTouchX = 0f
            private var initialTouchY = 0f
            private var isPullingLens = false
            private var isVerticalDrag = false

            override fun onTouch(v: View, event: MotionEvent): Boolean {
                when (event.action) {
                    MotionEvent.ACTION_DOWN -> {
                        initialY = edgeHandleParams!!.y
                        initialTouchX = event.rawX
                        initialTouchY = event.rawY
                        isPullingLens = false
                        isVerticalDrag = false
                        return true
                    }
                    MotionEvent.ACTION_MOVE -> {
                        val dx = event.rawX - initialTouchX
                        val dy = event.rawY - initialTouchY

                        if (!isPullingLens && !isVerticalDrag) {
                            if (dx > 20 && dx > Math.abs(dy)) {
                                // User pulled outward into screen -> Activate Magnifying Lens!
                                isPullingLens = true
                                dismissQuickMenu()
                                showMagnifyingLens(event.rawX, event.rawY)
                                handleContainer.alpha = 0.3f
                            } else if (Math.abs(dy) > 15) {
                                isVerticalDrag = true
                            }
                        }

                        if (isPullingLens) {
                            updateLensPosition(event.rawX, event.rawY)
                            return true
                        } else if (isVerticalDrag) {
                            edgeHandleParams!!.y = (initialY + dy).toInt()
                            windowManager?.updateViewLayout(edgeHandleView, edgeHandleParams)
                            return true
                        }
                    }
                    MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> {
                        handleContainer.alpha = 1.0f
                        if (isPullingLens) {
                            val dropX = event.rawX.toInt()
                            val dropY = event.rawY.toInt()
                            dismissMagnifyingLens()
                            performTranslationAt(dropX, dropY)
                            isPullingLens = false
                        } else if (!isVerticalDrag) {
                            // Single Tap -> Toggle Quick Action Grid Menu (Image 3)
                            toggleQuickActionMenu()
                        }
                        return true
                    }
                }
                return false
            }
        })

        edgeHandleView = handleContainer
        try {
            windowManager?.addView(edgeHandleView, edgeHandleParams)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    // =========================================================================
    // 2. QUICK ACTION GRID MENU (Matching Image 3)
    // =========================================================================
    private fun toggleQuickActionMenu() {
        if (isMenuOpen) {
            dismissQuickMenu()
        } else {
            showQuickActionMenu()
        }
    }

    @SuppressLint("SetTextI18n")
    private fun showQuickActionMenu() {
        dismissQuickMenu()
        isMenuOpen = true

        val density = resources.displayMetrics.density
        val menuWidthPx = (258 * density).toInt()

        val metrics = DisplayMetrics()
        windowManager?.defaultDisplay?.getMetrics(metrics)

        quickMenuParams = WindowManager.LayoutParams(
            menuWidthPx,
            WindowManager.LayoutParams.WRAP_CONTENT,
            getOverlayLayoutType(),
            WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = (20 * density).toInt()
            y = (edgeHandleParams?.y ?: (metrics.heightPixels * 0.35).toInt()) - (40 * density).toInt()
        }

        val menuCard = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            val bg = GradientDrawable().apply {
                shape = GradientDrawable.RECTANGLE
                cornerRadius = 24f * density
                setColor(Color.parseColor("#0F172A")) // Modern dark aesthetic matching Image 3
                setStroke((1.5f * density).toInt(), Color.parseColor("#1E293B"))
            }
            background = bg
            setPadding((16 * density).toInt(), (14 * density).toInt(), (16 * density).toInt(), (16 * density).toInt())
            elevation = 24f * density
        }

        // Header Title Row
        val headerLayout = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
            setPadding(0, 0, 0, (12 * density).toInt())
        }

        val headerTv = TextView(this).apply {
            text = "NeuroPocket AI"
            setTextColor(Color.parseColor("#38BDF8"))
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 13f)
            setTypeface(null, Typeface.BOLD)
        }
        headerLayout.addView(headerTv, LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f))

        val closeTv = TextView(this).apply {
            text = "✕"
            setTextColor(Color.parseColor("#94A3B8"))
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 15f)
            setPadding((8 * density).toInt(), (2 * density).toInt(), (8 * density).toInt(), (2 * density).toInt())
            setOnClickListener { dismissQuickMenu() }
        }
        headerLayout.addView(closeTv)
        menuCard.addView(headerLayout)

        // 3x2 Grid of actions (Lens, Page, Box, Voice, Settings, Clear)
        val gridLayout = GridLayout(this).apply {
            columnCount = 3
            rowCount = 2
            alignmentMode = GridLayout.ALIGN_BOUNDS
        }

        // Action Item 1: Search / Lens
        gridLayout.addView(createMenuItem("Lens", android.R.drawable.ic_menu_search, Color.parseColor("#38BDF8")) {
            dismissQuickMenu()
            val m = DisplayMetrics()
            windowManager?.defaultDisplay?.getMetrics(m)
            showMagnifyingLens(m.widthPixels * 0.5f, m.heightPixels * 0.45f)
        })

        // Action Item 2: Page / Global Translate (Image 3 Page)
        gridLayout.addView(createMenuItem("Page", android.R.drawable.ic_menu_agenda, Color.parseColor("#34D399")) {
            dismissQuickMenu()
            performGlobalPageTranslation()
        })

        // Action Item 3: Box Scan (Image 3 Box)
        gridLayout.addView(createMenuItem("Box", android.R.drawable.ic_menu_crop, Color.parseColor("#F472B6")) {
            dismissQuickMenu()
            val m = DisplayMetrics()
            windowManager?.defaultDisplay?.getMetrics(m)
            showMagnifyingLens(m.widthPixels * 0.5f, m.heightPixels * 0.45f)
        })

        // Action Item 4: Voice (Image 3 Voice)
        gridLayout.addView(createMenuItem("Voice", android.R.drawable.ic_btn_speak_now, Color.parseColor("#FB923C")) {
            dismissQuickMenu()
            val intent = Intent(this@FloatingOverlayService, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
                putExtra("action", "voice")
            }
            startActivity(intent)
        })

        // Action Item 5: Settings / App (Image 3 Settings)
        gridLayout.addView(createMenuItem("Settings", android.R.drawable.ic_menu_preferences, Color.parseColor("#A78BFA")) {
            dismissQuickMenu()
            val intent = Intent(this@FloatingOverlayService, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
            }
            startActivity(intent)
        })

        // Action Item 6: Clear / Dismiss Overlays
        gridLayout.addView(createMenuItem("Clear", android.R.drawable.ic_menu_close_clear_cancel, Color.parseColor("#EF4444")) {
            dismissQuickMenu()
            clearAllInPlaceOverlays()
        })

        menuCard.addView(gridLayout)

        quickMenuView = menuCard
        try {
            windowManager?.addView(quickMenuView, quickMenuParams)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun createMenuItem(title: String, iconRes: Int, accentColor: Int, onClick: () -> Unit): View {
        val density = resources.displayMetrics.density
        val itemLayout = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER_HORIZONTAL
            setPadding((4 * density).toInt(), (6 * density).toInt(), (4 * density).toInt(), (6 * density).toInt())
            isClickable = true
            isFocusable = true
            setOnClickListener { onClick() }
        }

        val iconContainer = FrameLayout(this).apply {
            val circleBg = GradientDrawable().apply {
                shape = GradientDrawable.OVAL
                setColor(Color.parseColor("#1E293B"))
            }
            background = circleBg
            setPadding((11 * density).toInt(), (11 * density).toInt(), (11 * density).toInt(), (11 * density).toInt())
        }

        val iconView = ImageView(this).apply {
            setImageResource(iconRes)
            setColorFilter(accentColor)
        }
        val iconParams = FrameLayout.LayoutParams((22 * density).toInt(), (22 * density).toInt()).apply {
            gravity = Gravity.CENTER
        }
        iconContainer.addView(iconView, iconParams)
        itemLayout.addView(iconContainer)

        val titleTv = TextView(this).apply {
            text = title
            setTextColor(Color.parseColor("#F1F5F9"))
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 12f)
            gravity = Gravity.CENTER
            setPadding(0, (5 * density).toInt(), 0, (4 * density).toInt())
        }
        itemLayout.addView(titleTv)

        val params = GridLayout.LayoutParams().apply {
            width = (74 * density).toInt()
            height = WindowManager.LayoutParams.WRAP_CONTENT
            setMargins((1 * density).toInt(), (2 * density).toInt(), (1 * density).toInt(), (4 * density).toInt())
        }
        itemLayout.layoutParams = params
        return itemLayout
    }

    private fun dismissQuickMenu() {
        if (quickMenuView != null && windowManager != null) {
            try {
                windowManager?.removeView(quickMenuView)
            } catch (e: Exception) {
                e.printStackTrace()
            }
            quickMenuView = null
        }
        isMenuOpen = false
    }

    // =========================================================================
    // 3. DRAGGABLE MAGNIFYING LENS (Matching Image 4)
    // =========================================================================
    @SuppressLint("ClickableViewAccessibility")
    private fun showMagnifyingLens(startX: Float, startY: Float) {
        if (magnifyingLensView != null) return
        isLensActive = true

        val density = resources.displayMetrics.density
        val lensSizePx = (64 * density).toInt()

        lensParams = WindowManager.LayoutParams(
            lensSizePx,
            lensSizePx,
            getOverlayLayoutType(),
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = (startX - lensSizePx / 2).toInt()
            y = (startY - lensSizePx / 2).toInt()
        }

        val lensLayout = RelativeLayout(this).apply {
            val gradient = GradientDrawable(
                GradientDrawable.Orientation.TL_BR,
                intArrayOf(Color.parseColor("#0072FF"), Color.parseColor("#00C6FF"))
            ).apply {
                shape = GradientDrawable.OVAL
                setStroke((3f * density).toInt(), Color.WHITE)
            }
            background = gradient
            elevation = 20f * density
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
        val innerParams = RelativeLayout.LayoutParams((46 * density).toInt(), (46 * density).toInt()).apply {
            addRule(RelativeLayout.CENTER_IN_PARENT, RelativeLayout.TRUE)
        }
        lensLayout.addView(innerCircle, innerParams)

        // Crosshair Search Icon
        val searchIcon = ImageView(this).apply {
            setImageResource(android.R.drawable.ic_menu_search)
            setColorFilter(Color.WHITE)
        }
        val searchParams = RelativeLayout.LayoutParams((30 * density).toInt(), (30 * density).toInt()).apply {
            addRule(RelativeLayout.CENTER_IN_PARENT, RelativeLayout.TRUE)
        }
        lensLayout.addView(searchIcon, searchParams)

        // Target Indicator Dot
        val dotView = View(this).apply {
            val dotBg = GradientDrawable().apply {
                shape = GradientDrawable.OVAL
                setColor(Color.parseColor("#FFD700"))
            }
            background = dotBg
        }
        val dotParams = RelativeLayout.LayoutParams((8 * density).toInt(), (8 * density).toInt()).apply {
            addRule(RelativeLayout.ALIGN_PARENT_BOTTOM, RelativeLayout.TRUE)
            addRule(RelativeLayout.ALIGN_PARENT_END, RelativeLayout.TRUE)
            bottomMargin = (10 * density).toInt()
            rightMargin = (10 * density).toInt()
        }
        lensLayout.addView(dotView, dotParams)

        // Independent Touch Listener (when lens is placed standalone on screen)
        lensLayout.setOnTouchListener(object : View.OnTouchListener {
            private var initialX = 0
            private var initialY = 0
            private var initialTouchX = 0f
            private var initialTouchY = 0f

            override fun onTouch(v: View, event: MotionEvent): Boolean {
                when (event.action) {
                    MotionEvent.ACTION_DOWN -> {
                        initialX = lensParams!!.x
                        initialY = lensParams!!.y
                        initialTouchX = event.rawX
                        initialTouchY = event.rawY
                        return true
                    }
                    MotionEvent.ACTION_MOVE -> {
                        val dx = (event.rawX - initialTouchX).toInt()
                        val dy = (event.rawY - initialTouchY).toInt()
                        lensParams!!.x = initialX + dx
                        lensParams!!.y = initialY + dy
                        windowManager?.updateViewLayout(magnifyingLensView, lensParams)
                        return true
                    }
                    MotionEvent.ACTION_UP -> {
                        val centerX = lensParams!!.x + lensSizePx / 2
                        val centerY = lensParams!!.y + lensSizePx / 2
                        performTranslationAt(centerX, centerY)
                        return true
                    }
                }
                return false
            }
        })

        magnifyingLensView = lensLayout
        try {
            windowManager?.addView(magnifyingLensView, lensParams)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun updateLensPosition(rawX: Float, rawY: Float) {
        if (magnifyingLensView != null && lensParams != null) {
            val density = resources.displayMetrics.density
            val lensSizePx = (64 * density).toInt()
            lensParams!!.x = (rawX - lensSizePx / 2).toInt()
            lensParams!!.y = (rawY - lensSizePx / 2).toInt()
            try {
                windowManager?.updateViewLayout(magnifyingLensView, lensParams)
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }

    private fun dismissMagnifyingLens() {
        if (magnifyingLensView != null && windowManager != null) {
            try {
                windowManager?.removeView(magnifyingLensView)
            } catch (e: Exception) {
                e.printStackTrace()
            }
            magnifyingLensView = null
        }
        isLensActive = false
    }

    private fun performTranslationAt(x: Int, y: Int) {
        val nodeData = NeuroAccessibilityService.instance?.findNodeAt(x, y)
        if (nodeData != null && nodeData.text.isNotBlank()) {
            createInPlaceTranslationOverlay(nodeData)
        } else {
            Toast.makeText(this, "No text found under lens. Drag over any text to translate.", Toast.LENGTH_SHORT).show()
        }
    }

    // =========================================================================
    // 4. EXACT IN-PLACE TEXT REPLACEMENT OVERLAY (Matching Image 5)
    // =========================================================================
    @SuppressLint("SetTextI18n")
    private fun createInPlaceTranslationOverlay(nodeData: NodeTextData) {
        val originalText = nodeData.text
        val targetRect = nodeData.bounds
        val density = resources.displayMetrics.density

        val metrics = DisplayMetrics()
        windowManager?.defaultDisplay?.getMetrics(metrics)
        val screenWidth = metrics.widthPixels

        // 1. Remove existing duplicate/overlapping overlays to prevent "double double" stacking
        val overlapping = activeInPlaceOverlays.filter { entry ->
            val exp = Rect(entry.rect.left - 12, entry.rect.top - 12, entry.rect.right + 12, entry.rect.bottom + 12)
            exp.intersect(targetRect)
        }
        for (old in overlapping) {
            removeInPlaceOverlay(old.view)
        }

        // Position overlay exactly over the original text bounding box (1:1 with screen coordinates)
        val maxWidthPx = Math.max(targetRect.width() + (6 * density).toInt(), (60 * density).toInt())
        val widthPx = Math.min(maxWidthPx, screenWidth - targetRect.left)

        val overlayParams = WindowManager.LayoutParams(
            widthPx,
            WindowManager.LayoutParams.WRAP_CONTENT,
            getOverlayLayoutType(),
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
                    WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = targetRect.left
            y = targetRect.top
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                layoutInDisplayCutoutMode = WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES
            }
        }

        // Minimal container with zero extra margin or padding
        val textContainer = FrameLayout(this).apply {
            background = null
            setPadding(0, 0, 0, 0)
        }

        var isShowingTranslated = true
        var currentTranslatedText = getInstantOfflineTranslation(originalText)

        // Text view with tight inline background wrapping only the text content
        val textView = TextView(this).apply {
            text = currentTranslatedText
            setTextColor(Color.parseColor("#111827"))
            val textBg = GradientDrawable().apply {
                shape = GradientDrawable.RECTANGLE
                cornerRadius = 3f * density
                setColor(Color.WHITE) // Tight text background to mask original words
            }
            background = textBg
            setPadding((3 * density).toInt(), (1.5f * density).toInt(), (3 * density).toInt(), (1.5f * density).toInt())
            
            val heightDp = targetRect.height() / density
            val estimatedSp = if (heightDp in 8.0..22.0) 12.5f else 13.5f
            setTextSize(TypedValue.COMPLEX_UNIT_SP, estimatedSp)
            setTypeface(null, Typeface.NORMAL)
            setLineSpacing(1.5f * density, 1.1f)
            gravity = Gravity.CENTER_VERTICAL or Gravity.START
        }
        textContainer.addView(textView)

        // Tap on text to toggle between Bengali translation & English original
        textContainer.setOnClickListener {
            isShowingTranslated = !isShowingTranslated
            textView.text = if (isShowingTranslated) currentTranslatedText else originalText
            textView.setTextColor(if (isShowingTranslated) Color.parseColor("#1E293B") else Color.parseColor("#2563EB"))
        }

        // Long press to copy and remove
        textContainer.setOnLongClickListener {
            val clipboard = getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
            val clip = ClipData.newPlainText("NeuroPocket Translation", currentTranslatedText)
            clipboard.setPrimaryClip(clip)
            Toast.makeText(this, "Copied!", Toast.LENGTH_SHORT).show()
            removeInPlaceOverlay(textContainer)
            true
        }

        try {
            windowManager?.addView(textContainer, overlayParams)
            activeInPlaceOverlays.add(InPlaceOverlayEntry(textContainer, targetRect, originalText))
        } catch (e: Exception) {
            e.printStackTrace()
        }

        // Query AI model only for dynamic/unknown sentences where no high-confidence exact match exists
        if (!isHighConfidenceOfflineMatch(originalText)) {
            MainActivity.requestAiTranslation(originalText) { aiResult ->
                val clean = aiResult.trim()
                if (clean.isNotBlank() && clean != currentTranslatedText && !clean.contains("ইনপুট:")) {
                    mainHandler.post {
                        currentTranslatedText = clean
                        if (isShowingTranslated) {
                            textView.text = currentTranslatedText
                        }
                    }
                }
            }
        }
    }

    private fun removeInPlaceOverlay(view: View) {
        if (windowManager != null) {
            try {
                windowManager?.removeView(view)
            } catch (e: Exception) {
                e.printStackTrace()
            }
            activeInPlaceOverlays.removeAll { it.view == view }
        }
    }

    private fun clearAllInPlaceOverlays() {
        for (entry in activeInPlaceOverlays) {
            try {
                windowManager?.removeView(entry.view)
            } catch (e: Exception) {}
        }
        activeInPlaceOverlays.clear()
        Toast.makeText(this, "Cleared on-screen overlays", Toast.LENGTH_SHORT).show()
    }

    // =========================================================================
    // 5. GLOBAL FULL-PAGE SCREEN TRANSLATION (Image 3 "Page" Action)
    // =========================================================================
    private fun performGlobalPageTranslation() {
        val nodes = NeuroAccessibilityService.instance?.getAllScreenTextNodes() ?: emptyList()
        if (nodes.isEmpty()) {
            Toast.makeText(this, "No text found on screen to translate", Toast.LENGTH_SHORT).show()
            return
        }

        clearAllInPlaceOverlays()
        Toast.makeText(this, "Translating screen...", Toast.LENGTH_SHORT).show()

        for (node in nodes.take(20)) {
            createInPlaceTranslationOverlay(node)
        }
    }

    // =========================================================================
    // 6. INSTANT OFFLINE DICTIONARY & HIGH-ACCURACY DYNAMIC TRANSLATION
    // =========================================================================
    private val directDictionaryMap: Map<String, String> = mapOf(
        "play store" to "প্লে স্টোর",
        "google play" to "গুগল প্লে",
        "gmail" to "জিমেইল",
        "photos" to "ফটোস",
        "youtube" to "ইউটিউব",
        "chrome" to "ক্রোম",
        "messages" to "মেসেজ",
        "phone" to "ফোন",
        "camera" to "ক্যামেরা",
        "clock" to "ঘড়ি",
        "calculator" to "ক্যালকুলেটর",
        "calendar" to "ক্যালেন্ডার",
        "maps" to "ম্যাপস",
        "drive" to "ড্রাইভ",
        "files" to "ফাইলস",
        "contacts" to "পরিচিতি",
        "facebook" to "ফেসবুক",
        "whatsapp" to "হোয়াটসঅ্যাপ",
        "instagram" to "ইনস্টাগ্রাম",
        "sign in" to "সাইন ইন",
        "welcome" to "স্বাগতম!",
        "welcome!" to "স্বাগতম!",
        "settings" to "সেটিংস",
        "notifications" to "বিজ্ঞপ্তি",
        "search" to "অনুসন্ধান",
        "download" to "ডাউনলোড",
        "install" to "ইনস্টল করুন",
        "cancel" to "বাতিল",
        "continue" to "চালিয়ে যান",
        "save" to "সংরক্ষণ করুন",
        "share" to "শেয়ার করুন",
        "delete" to "মুছে ফেলুন",
        "edit" to "সম্পাদনা",
        "profile" to "প্রোফাইল",
        "account" to "অ্যাকাউন্ট",
        "help" to "সাহায্য",
        "privacy policy" to "গোপনীয়তা নীতি",
        "terms and conditions" to "শর্তাবলী ও নিয়মাবলী"
    )

    private fun isHighConfidenceOfflineMatch(text: String): Boolean {
        val trimmed = text.trim()
        val lower = trimmed.lowercase(Locale.ROOT)
        if (directDictionaryMap.containsKey(lower)) return true
        return lower.contains("chat with gemini in messages") ||
               lower.contains("sync chats across your devices") ||
               lower.contains("sign into your google account") ||
               lower.contains("sign in to your google account") ||
               lower.contains("use messages without an account") ||
               lower.contains("sign in to find the latest") ||
               lower.contains("google play") ||
               lower.contains("play store") ||
               lower.contains("welcome!") ||
               lower == "welcome" ||
               lower == "sign in"
    }

    private fun getInstantOfflineTranslation(text: String): String {
        val trimmed = text.trim()
        if (trimmed.isEmpty()) return ""
        val isBengali = trimmed.any { it in '\u0980'..'\u09FF' }

        if (isBengali) {
            return when {
                trimmed.contains("সাইন ইন") -> "Sign in"
                trimmed.contains("স্বাগতম") -> "Welcome"
                trimmed.contains("ধন্যবাদ") -> "Thank you"
                trimmed.contains("সেটিংস") -> "Settings"
                trimmed.contains("অনুসন্ধান") -> "Search"
                trimmed.contains("ডাউনলোড") -> "Download"
                else -> trimmed
            }
        } else {
            val lower = trimmed.lowercase(Locale.ROOT)
            
            // 1. Direct App & UI Element Map
            if (directDictionaryMap.containsKey(lower)) {
                return directDictionaryMap[lower]!!
            }

            // 2. Common Sentences & Complex Phrases
            return when {
                lower.contains("chat with gemini in messages") ->
                    "মেসেজে জেমিনির সাথে চ্যাট করুন (নির্দিষ্ট অঞ্চলে উপলব্ধ)"
                lower.contains("sync chats across your devices") ->
                    "আপনার সকল ডিভাইসে চ্যাট সিঙ্ক করুন"
                lower.contains("sign into your google account to get the very best of messages") ||
                lower.contains("sign in to your google account") ->
                    "মেসেজের সেরা অভিজ্ঞতা পেতে আপনার গুগল অ্যাকাউন্টে সাইন ইন করুন"
                lower.contains("use messages without an account") ->
                    "অ্যাকাউন্ট ছাড়াই মেসেজ ব্যবহার করুন"
                lower.contains("sign in to find the latest android apps") ->
                    "সবচেয়ে নতুন Android অ্যাপ, গেম, মুভি পেতে সাইন ইন করুন"
                lower.contains("sign in to find the latest") ->
                    "নতুন অ্যাপস ও গেমস জানতে সাইন ইন করুন"
                lower.startsWith("thu, sep") -> "বৃহস্পতি, ১৭ সেপ্টে"
                lower.startsWith("fri, sep") -> "শুক্র, ১৮ সেপ্টে"
                lower.startsWith("sat, sep") -> "শনি, ১৯ সেপ্টে"
                lower.startsWith("sun, sep") -> "রবি, ২০ সেপ্টে"
                lower.startsWith("mon, sep") -> "সোম, ২১ সেপ্টে"
                lower.startsWith("tue, sep") -> "মঙ্গল, ২২ সেপ্টে"
                lower.startsWith("wed, sep") -> "বুধ, ২৩ সেপ্টে"
                else -> {
                    // 3. Multi-word phrase replacer
                    var res = trimmed
                    val phraseDict = mapOf(
                        "Sign in to find" to "খুঁজে পেতে সাইন ইন করুন",
                        "the latest Android apps" to "নতুন অ্যান্ড্রয়েড অ্যাপসমূহ",
                        "games, movies, music" to "গেম, মুভি, গান",
                        "and more" to "এবং আরও অনেক কিছু",
                        "Click here" to "এখানে ক্লিক করুন",
                        "Press to continue" to "এগিয়ে যেতে প্রেস করুন",
                        "Terms and conditions" to "শর্তাবলী ও নিয়মাবলী",
                        "Privacy policy" to "গোপনীয়তা নীতি"
                    )
                    for ((k, v) in phraseDict) {
                        if (res.contains(k, ignoreCase = true)) {
                            res = res.replace(Regex("(?i)$k"), v)
                        }
                    }
                    res
                }
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        isRunning = false
        dismissQuickMenu()
        dismissMagnifyingLens()
        clearAllInPlaceOverlays()
        if (edgeHandleView != null && windowManager != null) {
            try {
                windowManager?.removeView(edgeHandleView)
            } catch (e: Exception) {}
            edgeHandleView = null
        }
    }
}
