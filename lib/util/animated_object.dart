import 'dart:ui';

import 'package:bonfire/decoration/decoration.dart';
import 'package:bonfire/player/player.dart';
import 'package:bonfire/util/rect_component.dart';
import 'package:flame/animation.dart' as FlameAnimation;

/// This represents a Component for your game in bonfire.
///
/// All components like [Enemy],[Player] and [GameDecoration] extends this.
class AnimatedObject extends RectComponent {
  /// Animation that will be drawn on the screen.
  FlameAnimation.Animation animation;

  @override
  void render(Canvas canvas) {
    if (animation == null || position == null) return;
    if (animation.loaded()) {
      animation.getSprite().renderRect(canvas, position);
    }
  }

  @override
  void update(double dt) {
    if (animation != null) animation.update(dt);
    super.update(dt);
  }
}
