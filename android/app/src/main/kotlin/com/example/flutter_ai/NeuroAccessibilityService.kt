package com.example.flutter_ai

import android.accessibilityservice.AccessibilityService
import android.graphics.Rect
import android.os.Build
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo

data class NodeTextData(
    val text: String,
    val bounds: Rect
)

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
     * Inspects active window hierarchy and retrieves the best-matching text node at or nearest to coordinate (x, y).
     */
    fun findNodeAt(x: Int, y: Int): NodeTextData? {
        val allNodes = getAllScreenTextNodes()
        if (allNodes.isEmpty()) return null

        // Priority 1: Exact or Expanded bounding box match
        val tolerance = 24
        val containingNodes = allNodes.filter { node ->
            val b = node.bounds
            val exp = Rect(b.left - tolerance, b.top - tolerance, b.right + tolerance, b.bottom + tolerance)
            exp.contains(x, y)
        }

        if (containingNodes.isNotEmpty()) {
            // Pick the most specific (smallest area) text node containing the coordinate
            return containingNodes.minByOrNull { it.bounds.width() * it.bounds.height() }
        }

        // Priority 2: Closest text node within 180px radius
        var closestNode: NodeTextData? = null
        var minDistance = Double.MAX_VALUE
        val maxReachRadius = 220.0

        for (node in allNodes) {
            val cx = node.bounds.centerX().toDouble()
            val cy = node.bounds.centerY().toDouble()
            val dist = Math.hypot(cx - x, cy - y)
            if (dist < minDistance && dist <= maxReachRadius) {
                minDistance = dist
                closestNode = node
            }
        }

        return closestNode
    }

    /**
     * Extracts all visible text nodes across the active screen for Page / Target translation.
     */
    fun getAllScreenTextNodes(): List<NodeTextData> {
        val list = mutableListOf<NodeTextData>()

        // 1. Check all interactive windows
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            val windowList = windows
            if (windowList != null && windowList.isNotEmpty()) {
                for (w in windowList.reversed()) {
                    val root = w.root ?: continue
                    if (root.packageName == packageName) continue // Skip own app overlay
                    collectAllTextNodesRecursively(root, list)
                }
                if (list.isNotEmpty()) return list
            }
        }

        // 2. Fallback to active root window
        val root = rootInActiveWindow
        if (root != null && root.packageName != packageName) {
            collectAllTextNodesRecursively(root, list)
        }
        return list
    }

    private fun collectAllTextNodesRecursively(node: AccessibilityNodeInfo?, list: MutableList<NodeTextData>) {
        if (node == null) return

        val rect = Rect()
        node.getBoundsInScreen(rect)

        val rawText = node.text?.toString() ?: node.contentDescription?.toString()
        val cleanText = rawText?.trim()

        if (!cleanText.isNullOrBlank() && rect.width() > 10 && rect.height() > 10) {
            // Avoid adding parent container if exact text or smaller child node is already captured
            val isDuplicate = list.any { existing ->
                existing.bounds == rect ||
                (existing.bounds.contains(rect) && existing.text == cleanText) ||
                (rect.contains(existing.bounds) && (cleanText == existing.text || cleanText.contains(existing.text)))
            }
            if (!isDuplicate) {
                list.add(NodeTextData(cleanText, rect))
            }
        }

        val count = node.childCount
        for (i in 0 until count) {
            val child = node.getChild(i)
            if (child != null) {
                collectAllTextNodesRecursively(child, list)
            }
        }
    }
}
