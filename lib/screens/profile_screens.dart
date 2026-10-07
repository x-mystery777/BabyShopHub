import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_colors.dart';
import '../core/format.dart';
import '../models/models.dart';
import '../services/shop_api.dart';
import '../state/session.dart';
import '../widgets/common.dart';
import 'admin_screens.dart';
import 'cart_screens.dart' show paymentMethods, paymentPrefKey;
import 'main_shell.dart';
import 'support_screens.dart';

/// Profile tab.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AsyncView<Profile>(
      load: ShopApi.profile,
      builder: (context, p, reload) {
        Widget tile(IconData icon, String label, VoidCallback onTap,
                {Color? color}) =>
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SoftCard(
                onTap: onTap,
                child: Row(
                  children: [
                    Icon(icon, color: color ?? AppColors.blue),
                    const SizedBox(width: 14),
                    Expanded(
                        child: Text(label,
                            style: TextStyle(
                                color: color ?? AppColors.navy,
                                fontWeight: FontWeight.w600))),
                    const Icon(Icons.chevron_right, color: AppColors.hint),
                  ],
                ),
              ),
            );

        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            const Center(
              child: Text('My Profile',
                  style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 18,
                      fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.blueTint,
                  child: Text(p.name.isEmpty ? '?' : p.name[0].toUpperCase(),
                      style: const TextStyle(
                          color: AppColors.blue,
                          fontSize: 26,
                          fontWeight: FontWeight.w800)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name,
                          style: const TextStyle(
                              color: AppColors.navy,
                              fontSize: 18,
                              fontWeight: FontWeight.w800)),
                      Text(p.email,
                          style: const TextStyle(color: AppColors.slate)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            tile(Icons.person_outline, 'Personal Information', () async {
              await pushPage(context, PersonalInfoScreen(profile: p));
              reload();
            }),
            tile(Icons.location_on_outlined, 'Delivery Addresses',
                () => pushPage(context, const AddressesScreen())),
            tile(Icons.credit_card_outlined, 'Payment Methods',
                () => pushPage(context, const PaymentMethodsScreen())),
            tile(Icons.receipt_long_outlined, 'Order History',
                () => MainShell.goTo(context, 3)),
            tile(Icons.lock_outline, 'Change Password',
                () => pushPage(context, const ChangePasswordScreen())),
            tile(Icons.help_outline, 'Help & Support',
                () => pushPage(context, const HelpSupportScreen())),
            if (Session.instance.isAdmin)
              tile(Icons.admin_panel_settings_outlined, 'Admin Panel',
                  () => pushPage(context, const AdminDashboardScreen())),
            tile(Icons.logout, 'Log Out', () async {
              if (await confirmDialog(
                  context, 'Log out', 'Do you want to log out?',
                  confirm: 'Log out')) {
                await Session.instance.logout();
              }
            }, color: AppColors.error),
          ],
        );
      },
    );
  }
}

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key, required this.profile});
  final Profile profile;

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.profile.name);
  late final _phone =
      TextEditingController(text: widget.profile.phoneNumber ?? '');
  late DateTime? _dob = widget.profile.dob;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(2000),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _dob = picked);
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    if (_dob == null) {
      showMessage(context, 'Choose your date of birth.', error: true);
      return;
    }
    setState(() => _saving = true);
    try {
      await ShopApi.updateProfile(_name.text.trim(), _phone.text.trim(), _dob!);
      if (!mounted) return;
      showMessage(context, 'Profile updated');
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        showMessage(context, e.toString(), error: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Personal Information')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              initialValue: widget.profile.email,
              enabled: false,
              decoration: fieldDecoration('Email', icon: Icons.mail_outline),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: fieldDecoration('Full name', icon: Icons.person_outline),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Enter your name.' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: fieldDecoration('Phone number', icon: Icons.phone_outlined),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Enter your phone number.' : null,
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickDob,
              borderRadius: BorderRadius.circular(14),
              child: InputDecorator(
                decoration:
                    fieldDecoration('Date of birth', icon: Icons.cake_outlined),
                child: Text(
                    _dob == null ? 'Choose date of birth' : formatDate(_dob),
                    style: TextStyle(
                        color: _dob == null ? AppColors.hint : AppColors.ink)),
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(label: 'Save Changes', loading: _saving, onPressed: _save),
          ],
        ),
      ),
    );
  }
}

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  Key _refreshKey = UniqueKey();

  Future<void> _open([Address? a]) async {
    final saved = await pushPage<bool>(context, AddressFormScreen(address: a));
    if (saved == true) setState(() => _refreshKey = UniqueKey());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Delivery Addresses')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.blue,
        foregroundColor: Colors.white,
        onPressed: () => _open(),
        icon: const Icon(Icons.add),
        label: const Text('Add address'),
      ),
      body: AsyncView<List<Address>>(
        key: _refreshKey,
        load: ShopApi.addresses,
        builder: (context, list, reload) {
          if (list.isEmpty) {
            return ListView(children: const [
              SizedBox(height: 80),
              EmptyView('No saved addresses yet.',
                  icon: Icons.location_off_outlined),
            ]);
          }
          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 90),
            itemCount: list.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final a = list[i];
              return SoftCard(
                child: Row(
                  children: [
                    const Icon(Icons.location_on_outlined, color: AppColors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Text(
                                (a.label ?? '').isEmpty ? 'Address' : a.label!,
                                style: const TextStyle(
                                    color: AppColors.navy,
                                    fontWeight: FontWeight.w700)),
                            if (a.isDefault) ...[
                              const SizedBox(width: 8),
                              const StatusChip('PAID', label: 'Default'),
                            ],
                          ]),
                          const SizedBox(height: 2),
                          Text(a.oneLine,
                              style: const TextStyle(color: AppColors.slate)),
                        ],
                      ),
                    ),
                    IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        onPressed: () => _open(a)),
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          size: 20, color: AppColors.error),
                      onPressed: () async {
                        if (!await confirmDialog(context, 'Delete address',
                            'Remove this address?',
                            confirm: 'Delete')) {
                          return;
                        }
                        try {
                          await ShopApi.deleteAddress(a.id);
                          reload();
                        } catch (e) {
                          if (context.mounted) {
                            showMessage(context, e.toString(), error: true);
                          }
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Add or edit an address. Pops with `true` when saved.
class AddressFormScreen extends StatefulWidget {
  const AddressFormScreen({super.key, this.address});
  final Address? address;

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _form = GlobalKey<FormState>();
  late final _label = TextEditingController(text: widget.address?.label ?? '');
  late final _line1 = TextEditingController(text: widget.address?.line1 ?? '');
  late final _city = TextEditingController(text: widget.address?.city ?? '');
  late final _state = TextEditingController(text: widget.address?.state ?? '');
  late final _country =
      TextEditingController(text: widget.address?.country ?? 'Nigeria');
  late final _postal =
      TextEditingController(text: widget.address?.postalCode ?? '');
  late bool _default = widget.address?.isDefault ?? false;
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [_label, _line1, _city, _state, _country, _postal]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    final body = {
      'label': _label.text.trim(),
      'line1': _line1.text.trim(),
      'city': _city.text.trim(),
      'state': _state.text.trim(),
      'country': _country.text.trim(),
      'postalCode': _postal.text.trim(),
      'default': _default,
    };
    try {
      if (widget.address == null) {
        await ShopApi.addAddress(body);
      } else {
        await ShopApi.updateAddress(widget.address!.id, body);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        showMessage(context, e.toString(), error: true);
      }
    }
  }

  String? _required(String? v) =>
      v == null || v.trim().isEmpty ? 'Required.' : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.address == null ? 'Add Address' : 'Edit Address')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
                controller: _label,
                decoration: fieldDecoration('Label (Home, Office...)')),
            const SizedBox(height: 12),
            TextFormField(
                controller: _line1,
                decoration: fieldDecoration('Street address'),
                validator: _required),
            const SizedBox(height: 12),
            TextFormField(
                controller: _city,
                decoration: fieldDecoration('City'),
                validator: _required),
            const SizedBox(height: 12),
            TextFormField(
                controller: _state, decoration: fieldDecoration('State')),
            const SizedBox(height: 12),
            TextFormField(
                controller: _country,
                decoration: fieldDecoration('Country'),
                validator: _required),
            const SizedBox(height: 12),
            TextFormField(
                controller: _postal,
                keyboardType: TextInputType.number,
                decoration: fieldDecoration('Postal code')),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Make this my default address'),
              value: _default,
              activeThumbColor: AppColors.blue,
              onChanged: (v) => setState(() => _default = v),
            ),
            const SizedBox(height: 12),
            PrimaryButton(label: 'Save Address', loading: _saving, onPressed: _save),
          ],
        ),
      ),
    );
  }
}

/// Payments are simulated. We only remember which method the shopper prefers.
class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  String _selected = paymentMethods.first;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((p) {
      final saved = p.getString(paymentPrefKey);
      if (saved != null && paymentMethods.contains(saved) && mounted) {
        setState(() => _selected = saved);
      }
    });
  }

  Future<void> _choose(String m) async {
    setState(() => _selected = m);
    final p = await SharedPreferences.getInstance();
    await p.setString(paymentPrefKey, m);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Methods')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Choose the method you want selected by default at checkout.',
              style: TextStyle(color: AppColors.slate)),
          const SizedBox(height: 14),
          for (final m in paymentMethods)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SoftCard(
                onTap: () => _choose(m),
                child: Row(
                  children: [
                    Icon(
                        m.startsWith('Card')
                            ? Icons.credit_card
                            : m.startsWith('Cash')
                                ? Icons.payments_outlined
                                : Icons.account_balance_wallet_outlined,
                        color: AppColors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Text(m,
                            style: const TextStyle(
                                color: AppColors.navy,
                                fontWeight: FontWeight.w600))),
                    Icon(
                        _selected == m
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: AppColors.blue),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          const Text(
              'BabyShopHub uses a simulated payment. No card numbers are collected or stored.',
              style: TextStyle(color: AppColors.hint, fontSize: 12)),
        ],
      ),
    );
  }
}

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _current.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final msg = await ShopApi.changePassword(_current.text, _new.text);
      if (!mounted) return;
      showMessage(context, msg);
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        showMessage(context, e.toString(), error: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change Password')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _current,
              obscureText: true,
              decoration: fieldDecoration('Current password', icon: Icons.lock_outline),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Enter your current password.' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _new,
              obscureText: true,
              decoration: fieldDecoration('New password', icon: Icons.lock_reset),
              validator: validateStrongPassword,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _confirm,
              obscureText: true,
              decoration: fieldDecoration('Confirm new password', icon: Icons.lock_reset),
              validator: (v) =>
                  v != _new.text ? 'Passwords do not match.' : null,
            ),
            const SizedBox(height: 24),
            PrimaryButton(label: 'Update Password', loading: _saving, onPressed: _save),
          ],
        ),
      ),
    );
  }
}