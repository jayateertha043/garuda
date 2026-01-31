import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:velocity_x/velocity_x.dart';

import '../providers.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: context.isMobile ? 95 : 70,
        ),
        Container(
          alignment: Alignment.topCenter,
          width: MediaQuery.of(context).size.width * 0.6,
          height: context.isMobile
              ? MediaQuery.of(context).size.height * 0.035
              : MediaQuery.of(context).size.height * 0.075,
          child: PointerInterceptor(
            child: Align(
              alignment: Alignment.center,
              child: Consumer(
                builder: (context, ref, child) {
                  return TextField(
                    minLines: null,
                    maxLines: null,
                    expands: true,
                    textAlign: TextAlign.center,
                    textAlignVertical: TextAlignVertical.center,
                    controller: null,
                    onChanged: (value) {
                      ref.read(searchProvider.notifier).state = value;
                    },
                    decoration: InputDecoration(
                      hintText: 'Search for tags, words ...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
