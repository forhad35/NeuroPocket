package com.example.flutter_ai

import android.accessibilityservice.AccessibilityService
import android.graphics.Rect
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo

class NeuroAccessibilityService : AccessibilityService() {

    companion object {
        var isServiceActive: Boolean = false
        var instance: NeuroAccessibilityService? = null
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        isServiceActive = true
        instance = this
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        // Active event listening
    }

    override fun onInterrupt() {
        isServiceActive = false
        instance = null
    }

    override fun onDestroy() {
        super.onDestroy()
        isServiceActive = false
        instance = null
    }

    /**
     * Inspects active window hierarchy and retrieves text located at screen coordinates (x, y).
     */
    fun findTextAt(x: Int, y: Int): String? {
        val root = rootInActiveWindow ?: return null
        return findTextInNode(root, x, y)
    }

    private fun findTextInNode(node: AccessibilityNodeInfo?, x: Int, y: Int): String? {
        if (node == null) return null
        val rect = Rect()
        node.getBoundsInScreen(rect)
        if (rect.contains(x, y)) {
            val text = node.text?.toString()
            if (!text.isNullOrBlank()) {
                return text
            }
            val count = node.childCount
            for (i in 0 until count) {
                val childText = findTextInNode(node.getChild(i), x, y)
                if (!childText.isNullOrBlank()) {
                    return childText
                }
            }
        }
        return null
    }
}
