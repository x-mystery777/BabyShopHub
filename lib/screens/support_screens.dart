import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/format.dart';
import '../models/models.dart';
import '../services/shop_api.dart';
import '../widgets/common.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Widget tile(IconData icon, String title, String sub, Widget page) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: SoftCard(
            onTap: () => pushPage(context, page),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                      color: AppColors.blueTint, shape: BoxShape.circle),
                  child: Icon(icon, color: AppColors.blue),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              color: AppColors.navy,
                              fontWeight: FontWeight.w700)),
                      Text(sub,
                          style: const TextStyle(
                              color: AppColors.slate, fontSize: 12)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.hint),
              ],
            ),
          ),
        );

    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          tile(Icons.quiz_outlined, 'FAQs & User Guide',
              'Find answers to common questions', const FaqScreen()),
          tile(Icons.mail_outline, 'Contact Us',
              'Get in touch with our support team',
              const TicketFormScreen(title: 'Contact Us', prefix: '')),
          tile(Icons.report_problem_outlined, 'Report an Issue',
              'Let us know about any problem',
              const TicketFormScreen(title: 'Report an Issue', prefix: 'Issue: ')),
          tile(Icons.favorite_border, 'Feedback', 'Share your thoughts with us',
              const TicketFormScreen(title: 'Feedback', prefix: 'Feedback: ')),
          tile(Icons.forum_outlined, 'My Tickets',
              'See replies from our team', const MyTicketsScreen()),
        ],
      ),
    );
  }
}

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  static const _faqs = [
    ('How do I create an account?',
        'Tap Sign Up, fill in your details and enter the 6-digit code we email you to verify your account.'),
    ('How do I find a product?',
        'Use the search bar on Home or browse Categories. You can search by product name, brand or category, and filter by brand.'),
    ('How do I order?',
        'Open a product, tap Add to Cart, then go to Cart > Proceed to Checkout. Choose a delivery address and payment method, then Place Order.'),
    ('Is payment real?',
        'No. Payment is simulated for this app, so no money is taken and no card details are stored.'),
    ('How do I track my order?',
        'Open the Orders tab and tap an order. The tracking page updates automatically as the status changes.'),
    ('Can I cancel an order?',
        'Contact support from Help & Support. Orders can only be cancelled before they are shipped.'),
    ('How do I leave a review?',
        'Open the product page and tap "Write a review". Choose a star rating and add a comment.'),
    ('I forgot my password.',
        'On the login screen tap "Forgot password?", enter your email and use the code we send you.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FAQs & User Guide')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          for (final f in _faqs)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SoftCard(
                padding: EdgeInsets.zero,
                child: Theme(
                  data: Theme.of(context)
                      .copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    title: Text(f.$1,
                        style: const TextStyle(
                            color: AppColors.navy,
                            fontWeight: FontWeight.w600,
                            fontSize: 14)),
                    childrenPadding:
                        const EdgeInsets.fromLTRB(16, 0, 16, 14),
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(f.$2,
                          style: const TextStyle(
                              color: AppColors.slate, height: 1.4)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class TicketFormScreen extends StatefulWidget {
  const TicketFormScreen({super.key, required this.title, required this.prefix});
  final String title;
  final String prefix;

  @override
  State<TicketFormScreen> createState() => _TicketFormScreenState();
}

class _TicketFormScreenState extends State<TicketFormScreen> {
  final _form = GlobalKey<FormState>();
  final _subject = TextEditingController();
  final _message = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _subject.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _sending = true);
    try {
      await ShopApi.createTicket(
          '${widget.prefix}${_subject.text.trim()}', _message.text.trim());
      if (!mounted) return;
      showMessage(context, 'Sent! Our team will get back to you.');
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _sending = false);
        showMessage(context, e.toString(), error: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _subject,
              decoration: fieldDecoration('Subject'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Enter a subject.' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _message,
              maxLines: 6,
              decoration: fieldDecoration('Tell us more...'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Enter a message.' : null,
            ),
            const SizedBox(height: 24),
            PrimaryButton(label: 'Send', loading: _sending, onPressed: _send),
          ],
        ),
      ),
    );
  }
}

class MyTicketsScreen extends StatelessWidget {
  const MyTicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Tickets')),
      body: AsyncView<List<Ticket>>(
        load: ShopApi.myTickets,
        builder: (context, tickets, reload) {
          if (tickets.isEmpty) {
            return ListView(children: const [
              SizedBox(height: 80),
              EmptyView('You have not contacted support yet.',
                  icon: Icons.forum_outlined),
            ]);
          }
          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            itemCount: tickets.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final t = tickets[i];
              return SoftCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: Text(t.subject,
                                style: const TextStyle(
                                    color: AppColors.navy,
                                    fontWeight: FontWeight.w700))),
                        StatusChip(t.status),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(t.message,
                        style: const TextStyle(color: AppColors.ink)),
                    if ((t.adminResponse ?? '').isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: AppColors.blueTint,
                            borderRadius: BorderRadius.circular(10)),
                        child: Text('Support: ${t.adminResponse}',
                            style: const TextStyle(color: AppColors.navy)),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(formatDateTime(t.createdAt),
                        style:
                            const TextStyle(color: AppColors.hint, fontSize: 11)),
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