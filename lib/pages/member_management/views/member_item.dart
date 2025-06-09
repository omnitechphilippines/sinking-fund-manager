import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/member.dart';

class MemberItem extends ConsumerWidget {
  final Member member;
  final VoidCallback onTap;

  const MemberItem({super.key, required this.member, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(member.name, style: Theme.of(context).textTheme.titleLarge),
                  const Spacer(),
                  Text('Created: ${member.formattedCreatedDate}', style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
              Row(
                children: <Widget>[
                  Text('₱ ${member.formattedNumber} (${member.numberOfHeads})', style: Theme.of(context).textTheme.titleMedium),
                  const Spacer(),
                  Text('Updated: ${member.formattedUpdatedDate}', style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
