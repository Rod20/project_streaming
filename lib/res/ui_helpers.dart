import 'package:flutter/material.dart';

/// Contains useful functions to reduce boilerplate code
class UIHelper {
  // Vertical spacing constants. Adjust to your liking.
  static const double _VerticalSpaceSmall = 10.0;
  static const double _VerticalSpaceMedium = 20.0;
  static const double _VerticalSpaceLarge = 50.0;

  // Vertical spacing constants. Adjust to your liking.
  static const double _HorizontalSpaceSmall = 10.0;
  static const double _HorizontalSpaceMedium = 20.0;
  static const double _HorizontalSpaceLarge = 50.0;

  // Button Sizes
  static const double _smallButtonRadius = 10.0;
  static const double _smallButtonHeight = 30.0;

  // Create Post
  static const double _smallAvatarRadius = 40.0;

  /// Returns a vertical space with height set to [_VerticalSpaceSmall]
  static Widget verticalSpaceSmall() {
    return verticalSpace(_VerticalSpaceSmall);
  }

  /// Returns a vertical space with height set to [_VerticalSpaceMedium]
  static Widget verticalSpaceMedium() {
    return verticalSpace(_VerticalSpaceMedium);
  }

  /// Returns a vertical space with height set to [_VerticalSpaceLarge]
  static Widget verticalSpaceLarge() {
    return verticalSpace(_VerticalSpaceLarge);
  }

  /// Returns a vertical space equal to the [height] supplied
  static Widget verticalSpace(double height) {
    return SizedBox(height: height);
  }

  /// Returns a vertical space with height set to [_HorizontalSpaceSmall]
  static Widget horizontalSpaceSmall() {
    return horizontalSpace(_HorizontalSpaceSmall);
  }

  /// Returns a vertical space with height set to [_HorizontalSpaceMedium]
  static Widget horizontalSpaceMedium() {
    return horizontalSpace(_HorizontalSpaceMedium);
  }

  /// Returns a vertical space with height set to [HorizontalSpaceLarge]
  static Widget horizontalSpaceLarge() {
    return horizontalSpace(_HorizontalSpaceLarge);
  }

  /// Returns a vertical space equal to the [width] supplied
  static Widget horizontalSpace(double width) {
    return SizedBox(width: width);
  }

  // Return a _HorizontalSpaceSmall value
  double get HorizontalSpaceSmall => _HorizontalSpaceSmall;

  // Return a HorizontalSpaceMedium value
  double get HorizontalSpaceMedium => _HorizontalSpaceMedium;

  // Return a HorizontalSpaceLarge value
  double get HorizontalSpaceLarge => _HorizontalSpaceLarge;

  // Return Button Radius value (Small Button)
  static double get smallButtonRadius => _smallButtonRadius;

  // Return Button Height value (Small Button)
  static get smallButtonHeight => _smallButtonHeight;

  // Return post avatar small radius
  static get getSmallAvatarRadius => _smallAvatarRadius;
}
