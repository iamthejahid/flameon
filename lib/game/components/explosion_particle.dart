import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

class ExplosionParticle extends ParticleSystemComponent {
  ExplosionParticle({required Vector2 position})
    : super(
        position: position,
        particle: Particle.generate(
          count: 20,
          lifespan: 0.8,
          generator: (i) {
            final random = Random();
            return AcceleratedParticle(
              acceleration: Vector2(0, 200), // Gravity
              speed: Vector2(
                (random.nextDouble() - 0.5) * 400,
                (random.nextDouble() - 0.5) * 400,
              ),
              child: CircleParticle(
                radius: random.nextDouble() * 3 + 1,
                paint: Paint()
                  ..color = i % 2 == 0 ? Colors.orange : Colors.redAccent,
              ),
            );
          },
        ),
      );
}
