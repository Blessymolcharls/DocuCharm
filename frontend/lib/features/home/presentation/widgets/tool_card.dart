import "package:docucharm_frontend/features/processor/domain/tool_type.dart";
import "package:flutter/material.dart";

class ToolCard extends StatelessWidget {
  const ToolCard({super.key, required this.tool, required this.onTap});

  final ToolType tool;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.surface,
              colors.surface.withValues(alpha: 0.85),
            ],
          ),
          border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(tool.icon, color: colors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tool.title,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tool.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: colors.onSurface.withValues(alpha: 0.75)),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: colors.primary),
          ],
        ),
      ),
    );
  }
}
