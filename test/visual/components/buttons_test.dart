/// Visual tests for button components.
///
/// Tests button variants across different devices and themes.
library;

import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../config/device_profiles.dart';
import '../config/visual_test_helpers.dart';

void main() {
  group('Button Components', () {
    goldenTest(
      'ElevatedButton variants',
      fileName: 'elevated_button_variants',
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 300),
        children: [
          GoldenTestScenario(
            name: 'Primary',
            child: VisualTestWrapper(
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Iniciar Treino'),
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'Disabled',
            child: VisualTestWrapper(
              child: const ElevatedButton(
                onPressed: null,
                child: Text('Iniciar Treino'),
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'With Icon',
            child: VisualTestWrapper(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.play_arrow),
                label: const Text('Iniciar Treino'),
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'Loading State',
            child: VisualTestWrapper(
              child: const ElevatedButton(
                onPressed: null,
                child: Icon(Icons.hourglass_empty, size: 20),
              ),
            ),
          ),
        ],
      ),
    );

    goldenTest(
      'OutlinedButton variants',
      fileName: 'outlined_button_variants',
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 300),
        children: [
          GoldenTestScenario(
            name: 'Default',
            child: VisualTestWrapper(
              child: OutlinedButton(
                onPressed: () {},
                child: const Text('Ver Detalhes'),
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'Disabled',
            child: VisualTestWrapper(
              child: const OutlinedButton(
                onPressed: null,
                child: Text('Ver Detalhes'),
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'Destructive Style',
            child: VisualTestWrapper(
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
                child: const Text('Cancelar Plano'),
              ),
            ),
          ),
        ],
      ),
    );

    goldenTest(
      'TextButton variants',
      fileName: 'text_button_variants',
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 300),
        children: [
          GoldenTestScenario(
            name: 'Default',
            child: VisualTestWrapper(
              child: TextButton(
                onPressed: () {},
                child: const Text('Pular'),
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'With Icon',
            child: VisualTestWrapper(
              child: TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Continuar'),
              ),
            ),
          ),
        ],
      ),
    );

    goldenTest(
      'FloatingActionButton variants',
      fileName: 'fab_variants',
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 200),
        children: [
          GoldenTestScenario(
            name: 'Default',
            child: VisualTestWrapper(
              child: FloatingActionButton(
                onPressed: () {},
                child: const Icon(Icons.add),
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'Extended',
            child: VisualTestWrapper(
              child: FloatingActionButton.extended(
                onPressed: () {},
                icon: const Icon(Icons.fitness_center),
                label: const Text('Novo Treino'),
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'Small',
            child: VisualTestWrapper(
              child: FloatingActionButton.small(
                onPressed: () {},
                child: const Icon(Icons.edit),
              ),
            ),
          ),
        ],
      ),
    );

    // Multi-device test for button row layout
    for (final device in DeviceProfiles.critical) {
      goldenTest(
        'Button row on ${device.name}',
        fileName: 'button_row_${device.safeFileName}',
        constraints: BoxConstraints.tight(device.size),
        builder: () => FullScreenTestWrapper(
          child: Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {},
                            child: const Text('Recusar'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {},
                            child: const Text('Aceitar Plano'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        child: const Text('Iniciar Treino'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
  });
}
