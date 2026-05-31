import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/utils/enum_translations.dart';
import 'package:outventura/core/widgets/detail_section.dart';
import 'package:outventura/core/widgets/detail_sliver_header.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';
import 'package:outventura/l10n/app_localizations.dart';

class UserDetailPage extends ConsumerWidget {
  final User user;

  const UserDetailPage({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppLocalizations.of(context)!;
    final ColorScheme cs = Theme.of(context).colorScheme;

    final Color accentColor = user.active ? cs.primary : cs.error;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          DetailSliverHeader(
            title: s.userDetail,
            subtitle: user.active ? s.active : s.inactive,
            color: accentColor,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                24,
                20,
                MediaQuery.of(context).padding.bottom + 32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DetailSection(
                    title: s.generalInfo,
                    children: [
                      DetailRow(Icons.person_outline, s.name, '${user.name} ${user.surname}'),
                      DetailRow(Icons.email_outlined, s.email, user.email),
                      if (user.phone != null)
                        DetailRow(Icons.phone_outlined, s.phone, user.phone!),
                      DetailRow(Icons.badge_outlined, s.role, user.role.localizedLabel(s)),
                      DetailRow(
                        Icons.circle_outlined,
                        s.status,
                        user.active ? s.active : s.inactive,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
