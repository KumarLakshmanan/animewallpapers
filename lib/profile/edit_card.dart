import 'package:flutter/material.dart';
import 'package:frontendforever/controllers/data_controller.dart';
import 'package:get/get.dart';

class EditCardWidget extends StatelessWidget {
  final String title;
  final String value;
  final String noValue;
  final IconData icon;
  const EditCardWidget({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.noValue,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final dc = Get.find<DataController>();
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              InkWell(
                onTap: () {},
                child: Row(
                  children: [
                    Icon(
                      Icons.edit,
                      size: 16,
                      color: Color(
                        int.parse(
                          dc.prelogin!.theme.bottombaractive,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Edit",
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Color(
                              int.parse(
                                dc.prelogin!.theme.bottombaractive,
                              ),
                            ),
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          value == ""
              ? Column(
                  children: [
                    Text(
                      noValue,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.add,
                          size: 16,
                          color: Color(
                            int.parse(
                              dc.prelogin!.theme.bottombaractive,
                            ),
                          ),
                        ),
                        Text(
                          "Tap to edit",
                          style:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: Color(
                                      int.parse(
                                        dc.prelogin!.theme.bottombaractive,
                                      ),
                                    ),
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                  ],
                )
              : Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
        ],
      ),
    );
  }
}
