import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool switchValue;
  final void Function(bool)? onSwitchChange;
  final double sliderValue;
  final void Function(double)? onSliderChange;
  final void Function()? onTap;

  final Color textColor;

  const CustomListTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.switchValue,
    required this.onSwitchChange,
    required this.sliderValue,
    required this.onSliderChange,
    required this.onTap,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [
                Colors.purple,
                Colors.pink,
                Colors.red,
                Colors.orange,
                Colors.yellow,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
            child: SizedBox(
              height: 90,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          icon,
                          size: 35,
                          color: textColor,
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            Text(
                              subtitle,
                              style: TextStyle(color: textColor),
                            ),
                          ],
                        ),
                        const Expanded(child: SizedBox()),
                        CupertinoSwitch(
                          value: switchValue,
                          onChanged: onSwitchChange,
                        ),
                      ],
                    ),
                  ),
                  Slider(
                    min: 0,
                    max: 100,
                    value: sliderValue,
                    thumbColor: textColor,
                    activeColor: Colors.grey.withOpacity(0.5),
                    inactiveColor: Colors.transparent.withOpacity(0.15),
                    onChanged: onSliderChange,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
