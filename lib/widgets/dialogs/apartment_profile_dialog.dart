import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/apartment_avatar.dart';
import '../../core/utils/image_compressor.dart';
import '../../cubit/building_cubit.dart';
import '../../cubit/building_state.dart';
import '../common/app_button.dart';
import '../common/app_card.dart';
import 'apartment_payment_dialog.dart';

Future<void> showApartmentProfileDialog({
  required BuildContext context,
  required BuildingCubit cubit,
  int? aptNum,
}) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: ApartmentProfileScreen(cubit: cubit, initialAptNum: aptNum),
      ),
    ),
  );
}

class ApartmentProfileScreen extends StatefulWidget {
  final BuildingCubit cubit;
  final int? initialAptNum;

  const ApartmentProfileScreen({
    super.key,
    required this.cubit,
    this.initialAptNum,
  });

  @override
  State<ApartmentProfileScreen> createState() => _ApartmentProfileScreenState();
}

class _ApartmentProfileScreenState extends State<ApartmentProfileScreen> {
  final _picker = ImagePicker();
  final _nameCtrl = TextEditingController();
  final _floorCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _showPhoneToNeighbors = true;

  int? _aptNum;
  Uint8List? _pickedAvatarBytes;
  bool _removeAvatar = false;
  bool _pickingAvatar = false;

  final _oldPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _savingProfile = false;
  bool _savingPass = false;
  String? _passError;

  @override
  void initState() {
    super.initState();
    _aptNum = widget.initialAptNum ?? widget.cubit.state.myAptNum;
    _hydrateForApt(_aptNum);
  }

  void _hydrateForApt(int? aptNum) {
    if (aptNum == null) return;
    final state = widget.cubit.state;
    final profile = state.apartmentProfiles[aptNum];
    _nameCtrl.text = (profile?.displayName.isNotEmpty == true)
        ? profile!.displayName
        : (state.apartmentNames[aptNum] ?? '');
    _floorCtrl.text = profile?.floorNum ?? '';
    _phoneCtrl.text = profile?.phone ?? '';
    _showPhoneToNeighbors = profile?.showPhoneToNeighbors ?? true;
    _pickedAvatarBytes = null;
    _removeAvatar = false;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _floorCtrl.dispose();
    _phoneCtrl.dispose();
    _oldPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    if (_pickingAvatar || _savingProfile) return;
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 640,
      maxHeight: 640,
      imageQuality: 78,
    );
    if (file == null) return;
    if (mounted) setState(() => _pickingAvatar = true);
    try {
      final raw = await file.readAsBytes();
      final compressed = await compressReceiptImage(raw);
      if (mounted) {
        setState(() {
          _pickedAvatarBytes = compressed;
          _removeAvatar = false;
        });
      }
    } finally {
      if (mounted) setState(() => _pickingAvatar = false);
    }
  }

  Future<void> _saveProfile(int aptNum) async {
    setState(() => _savingProfile = true);
    final ok = await widget.cubit.updateOwnApartmentProfile(
      aptNum: aptNum,
      displayName: _nameCtrl.text.trim(),
      floorNum: _floorCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      showPhoneToNeighbors: _showPhoneToNeighbors,
      avatarBytes: _pickedAvatarBytes,
      removeAvatar: _removeAvatar,
    );
    if (mounted) {
      setState(() {
        _savingProfile = false;
        if (ok) {
          _pickedAvatarBytes = null;
          _removeAvatar = false;
        }
      });
    }
  }

  Future<void> _changePasscode(BuildingState state, int aptNum) async {
    final s = state.s;
    final oldP = _oldPassCtrl.text.trim();
    final newP = _newPassCtrl.text.trim();
    final confP = _confirmPassCtrl.text.trim();
    if (newP.length < 4) {
      setState(() => _passError = s.errPassTooShort);
      return;
    }
    if (newP != confP) {
      setState(() => _passError = s.errPassMismatch);
      return;
    }
    setState(() {
      _savingPass = true;
      _passError = null;
    });
    final err = await widget.cubit.changeOwnApartmentPasscode(
      aptNum: aptNum,
      oldPasscode: oldP,
      newPasscode: newP,
    );
    if (!mounted) return;
    if (err != null) {
      setState(() {
        _savingPass = false;
        _passError = err;
      });
      return;
    }
    _oldPassCtrl.clear();
    _newPassCtrl.clear();
    _confirmPassCtrl.clear();
    setState(() {
      _savingPass = false;
      _passError = null;
    });
  }

  Future<void> _openWhatsAppReset(BuildingState state, int aptNum) async {
    final label = state.aptLabel(aptNum);
    final msg = state.localeCode == 'en'
        ? 'Hello, please reset the apartment passcode for $label (Apt $aptNum) on MABNA CARE.'
        : 'السلام عليكم، أرجو إعادة تعيين كلمة سر الشقة لـ $label (شقة $aptNum) على تطبيق MABNA CARE.';
    final uri = Uri.parse(
      'https://wa.me/201021950445?text=${Uri.encodeComponent(msg)}',
    );
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BuildingCubit, BuildingState>(
      builder: (context, state) {
        final s = state.s;
        final isDark = state.isDarkMode;
        final m = state.currentMonth;
        final closedSet = state.closedAptNums.toSet();
        final maxClosed =
            closedSet.isEmpty ? 0 : closedSet.reduce((a, b) => a > b ? a : b);
        final activeBase = m?.aptsCount ?? 13;
        final totalApts = (activeBase + closedSet.length) > maxClosed
            ? (activeBase + closedSet.length)
            : maxClosed;

        final aptNum = _aptNum;
        final profile = aptNum != null ? state.apartmentProfiles[aptNum] : null;
        final isClosedApt = aptNum != null && closedSet.contains(aptNum);
        final hasPass =
            aptNum != null && (state.apartmentHasPasscode[aptNum] ?? false);
        final unlockedHere = aptNum != null &&
            (state.isAdminAuthenticated ||
                !state.requireAptPassOnOpen ||
                (hasPass &&
                    state.myAptNum == aptNum &&
                    (state.savedAptPass ?? '').isNotEmpty));

        final hasRemoteAvatar =
            !_removeAvatar && (profile?.hasAvatar ?? false);
        final hasAnyAvatar = _pickedAvatarBytes != null || hasRemoteAvatar;

        return Scaffold(
          backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
          appBar: AppBar(
            backgroundColor: AppColors.surface(isDark),
            elevation: 0,
            title: Text(
              s.myProfileTitle,
              style: AppTypography.headline.copyWith(
                color: AppColors.textPrimary(isDark),
              ),
            ),
          ),
          body: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: ListView(
                padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
                children: [
                  if (aptNum == null) ...[
                    AppCard(
                      padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            s.profileSelectAptFirst,
                            style: AppTypography.body.copyWith(
                              color: AppColors.textSecondary(isDark),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          DropdownButtonFormField<int>(
                            dropdownColor: AppColors.cardElevated(isDark),
                            decoration: InputDecoration(
                              labelText: s.selectAptBtn,
                              prefixIcon: const Icon(Icons.home_outlined, size: 18),
                            ),
                            items: List.generate(totalApts, (i) {
                              final n = i + 1;
                              final cTag = closedSet.contains(n) ? '🔒 ' : '';
                              return DropdownMenuItem<int>(
                                value: n,
                                child: Text('$cTag${state.aptLabel(n)}'),
                              );
                            }),
                            onChanged: (v) {
                              if (v == null) return;
                              widget.cubit.setMyApt(v);
                              setState(() {
                                _aptNum = v;
                                _hydrateForApt(v);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Hero & Profile Form Card
                    AppCard(
                      padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              InkWell(
                                onTap: unlockedHere ? _pickAvatar : null,
                                borderRadius: BorderRadius.circular(AppRadius.lg),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    _pickingAvatar
                                        ? Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [
                                                  AppColors.primary,
                                                  AppColors.emerald,
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                AppRadius.lg,
                                              ),
                                            ),
                                            alignment: Alignment.center,
                                            child: const SizedBox(
                                              width: 22,
                                              height: 22,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.2,
                                                color: Colors.white,
                                              ),
                                            ),
                                          )
                                        : ApartmentAvatar(
                                            aptNum: aptNum,
                                            avatarUrl: hasRemoteAvatar
                                                ? profile!.avatarUrl
                                                : null,
                                            localBytes: _pickedAvatarBytes,
                                            size: 60,
                                            borderRadius: AppRadius.lg,
                                          ),
                                    if (unlockedHere)
                                      PositionedDirectional(
                                        bottom: -4,
                                        end: -4,
                                        child: Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: AppColors.card(isDark),
                                              width: 2,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.camera_alt_rounded,
                                            size: 13,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      state.aptLabel(aptNum),
                                      style: AppTypography.title.copyWith(
                                        color: AppColors.textPrimary(isDark),
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      [
                                        s.defaultAptName(aptNum),
                                        if (_floorCtrl.text.trim().isNotEmpty)
                                          _floorCtrl.text.trim(),
                                      ].join(' • '),
                                      style: AppTypography.caption.copyWith(
                                        color: AppColors.textSecondary(isDark),
                                      ),
                                    ),
                                    if (unlockedHere) ...[
                                      const SizedBox(height: 6),
                                      Wrap(
                                        spacing: 8,
                                        children: [
                                          InkWell(
                                            onTap: _pickingAvatar
                                                ? null
                                                : _pickAvatar,
                                            child: Text(
                                              s.changePhotoBtn,
                                              style: AppTypography.caption.copyWith(
                                                color: AppColors.primaryText(isDark),
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                          if (hasAnyAvatar)
                                            InkWell(
                                              onTap: () => setState(() {
                                                _pickedAvatarBytes = null;
                                                _removeAvatar = true;
                                              }),
                                              child: Text(
                                                s.removePhotoBtn,
                                                style: AppTypography.caption.copyWith(
                                                  color: AppColors.dangerText(isDark),
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: (isClosedApt
                                          ? AppColors.amber
                                          : AppColors.emerald)
                                      .withValues(alpha: 0.14),
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.pill),
                                  border: Border.all(
                                    color: (isClosedApt
                                            ? AppColors.amber
                                            : AppColors.emerald)
                                        .withValues(alpha: 0.35),
                                  ),
                                ),
                                child: Text(
                                  isClosedApt
                                      ? s.aptStatusClosed
                                      : s.aptStatusActive,
                                  style: AppTypography.caption.copyWith(
                                    color: isClosedApt
                                        ? AppColors.amber
                                        : AppColors.emeraldText(isDark),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (!unlockedHere) ...[
                            const SizedBox(height: AppSpacing.md),
                            AppPrimaryButton(
                              label: s.passcodeLabel,
                              icon: Icons.vpn_key_outlined,
                              onPressed: () => showClosedApartmentPasscodeDialog(
                                context: context,
                                cubit: widget.cubit,
                                state: state,
                                aptNum: aptNum,
                              ),
                            ),
                          ] else ...[
                            const SizedBox(height: AppSpacing.lg),
                            TextField(
                              controller: _nameCtrl,
                              enabled: !_savingProfile,
                              decoration: InputDecoration(
                                labelText: s.optionalName,
                                prefixIcon: const Icon(
                                  Icons.person_outline_rounded,
                                  size: 18,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _floorCtrl,
                                    enabled: !_savingProfile,
                                    decoration: InputDecoration(
                                      labelText: s.floorLabel,
                                      hintText: s.floorHint,
                                      prefixIcon: const Icon(
                                        Icons.layers_outlined,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: TextField(
                                    controller: _phoneCtrl,
                                    enabled: !_savingProfile,
                                    keyboardType: TextInputType.phone,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'[0-9+\-\s]'),
                                      ),
                                    ],
                                    decoration: InputDecoration(
                                      labelText: s.phoneNumberLabel,
                                      hintText: s.phoneNumberHint,
                                      prefixIcon: const Icon(
                                        Icons.phone_outlined,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Material(
                              type: MaterialType.transparency,
                              child: SwitchListTile.adaptive(
                                contentPadding: EdgeInsets.zero,
                                value: _showPhoneToNeighbors,
                                onChanged: _savingProfile
                                    ? null
                                    : (v) => setState(
                                          () => _showPhoneToNeighbors = v,
                                        ),
                                title: Text(
                                  s.showPhoneToNeighborsLabel,
                                  style: AppTypography.label.copyWith(
                                    color: AppColors.textPrimary(isDark),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                subtitle: Text(
                                  s.showPhoneToNeighborsSub,
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.textSecondary(isDark),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            AppPrimaryButton(
                              label: s.saveProfileBtn,
                              icon: Icons.save_rounded,
                              loading: _savingProfile,
                              onPressed: (_savingProfile || _pickingAvatar)
                                  ? null
                                  : () => _saveProfile(aptNum),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Change Passcode Card
                    if (hasPass) ...[
                      AppCard(
                        padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.lock_reset_rounded,
                                  size: 20,
                                  color: AppColors.primaryText(isDark),
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Text(
                                  s.changeAptPassTitle,
                                  style: AppTypography.title.copyWith(
                                    color: AppColors.textPrimary(isDark),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            TextField(
                              controller: _oldPassCtrl,
                              obscureText: true,
                              enabled: !_savingPass,
                              decoration: InputDecoration(
                                labelText: s.currentPassLabel,
                                prefixIcon: const Icon(
                                  Icons.lock_outline_rounded,
                                  size: 18,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _newPassCtrl,
                                    obscureText: true,
                                    enabled: !_savingPass,
                                    decoration: InputDecoration(
                                      labelText: s.newPassLabel,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: TextField(
                                    controller: _confirmPassCtrl,
                                    obscureText: true,
                                    enabled: !_savingPass,
                                    decoration: InputDecoration(
                                      labelText: s.confirmNewPassLabel,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (_passError != null) ...[
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                _passError!,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.dangerText(isDark),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                            const SizedBox(height: AppSpacing.md),
                            AppPrimaryButton(
                              label: s.saveNewPassBtn,
                              icon: Icons.check_rounded,
                              loading: _savingPass,
                              onPressed: _savingPass
                                  ? null
                                  : () => _changePasscode(state, aptNum),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],

                    // Forgot Passcode / Reset Request Card
                    AppCard(
                      padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.help_outline_rounded,
                                size: 20,
                                color: AppColors.amber,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                s.forgotPassSectionTitle,
                                style: AppTypography.title.copyWith(
                                  color: AppColors.textPrimary(isDark),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            s.forgotPassDesc,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary(isDark),
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          OutlinedButton.icon(
                            onPressed: () => _openWhatsAppReset(state, aptNum),
                            icon: Icon(
                              Icons.chat_rounded,
                              size: 17,
                              color: AppColors.emeraldText(isDark),
                            ),
                            label: Text(
                              s.whatsappManagerBtn,
                              style: AppTypography.label.copyWith(
                                color: AppColors.emeraldText(isDark),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(
                                color: AppColors.emerald.withValues(alpha: 0.45),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppRadius.md),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
