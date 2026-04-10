import "package:docucharm_frontend/features/home/presentation/widgets/tool_card.dart";
import "package:docucharm_frontend/features/processor/domain/tool_type.dart";
import "package:docucharm_frontend/features/processor/presentation/screens/processor_screen.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tools = ToolType.values;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colors.primary.withValues(alpha: 0.2),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "DocuCharm",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),
                const SizedBox(height: 6),
                Text(
                  "Fast PDF tools for merge, split, convert, rotate, and view.",
                  style: Theme.of(context).textTheme.bodyLarge,
                ).animate().fadeIn(delay: 120.ms, duration: 400.ms),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.separated(
                    itemCount: tools.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final tool = tools[index];
                      return ToolCard(
                        tool: tool,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => ProcessorScreen(tool: tool)),
                          );
                        },
                      )
                          .animate(delay: Duration(milliseconds: 80 * index))
                          .fadeIn(duration: 350.ms)
                          .slideX(begin: 0.08, end: 0);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
