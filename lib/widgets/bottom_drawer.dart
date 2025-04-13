
import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final VoidCallback? onClose;

  const AppDrawer({
    Key? key,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.5, // Takes up half of the screen
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Menu',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo[800],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    if (onClose != null) {
                      onClose!();
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
            const Divider(color: Colors.indigo),
            const SizedBox(height: 8),
            _buildMenuItem(
              context,
              icon: Icons.store,
              title: 'Business Profile',
              onTap: () => _handleMenuItemTap(context, 'Business Profile'),
            ),
            _buildMenuItem(
              context,
              icon: Icons.settings,
              title: 'Settings',
              onTap: () => _handleMenuItemTap(context, 'Settings'),
            ),
            _buildMenuItem(
              context,
              icon: Icons.category,
              title: 'Categories',
              onTap: () => _handleMenuItemTap(context, 'Categories'),
            ),
            _buildMenuItem(
              context,
              icon: Icons.backup,
              title: 'Backup & Restore',
              onTap: () => _handleMenuItemTap(context, 'Backup & Restore'),
            ),
            _buildMenuItem(
              context,
              icon: Icons.help_outline,
              title: 'Help & Support',
              onTap: () => _handleMenuItemTap(context, 'Help & Support'),
            ),
            const Spacer(),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.indigo.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.indigo[800]),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'App version 1.0.0',
                      style: TextStyle(color: Colors.indigo[800]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        required VoidCallback onTap,
      }) {
    return ListTile(
      leading: Icon(icon, color: Colors.indigo[800]),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  void _handleMenuItemTap(BuildContext context, String itemName) {
    // Implement navigation or actions for menu items
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Selected: $itemName')),
    );
  }
}

// Helper method to show the drawer
void showAppDrawer(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const AppDrawer(),
  );
}