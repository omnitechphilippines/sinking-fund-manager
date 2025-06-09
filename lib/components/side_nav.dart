import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SideNav extends StatelessWidget {
  final String currentRoute;

  const SideNav({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF222D32),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: ListView(
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(gradient: LinearGradient(colors: <Color>[Color(0xFF1A2226), Color(0xFF1A2226)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
            child: Text('Sinking Fund Manager', style: TextStyle(color: Color(0xFFECECEC), fontSize: 32, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
          ),
          HoverListTile(icon: Icons.people, title: 'Member Management', route: '/member-management', currentRoute: currentRoute),
          HoverListTile(icon: Icons.money, title: 'Contribution Tracking', route: '/contribution-tracking', currentRoute: currentRoute),
          HoverListTile(icon: Icons.handshake, title: 'Loan Management', route: '/loan-management', currentRoute: currentRoute),
          HoverListTile(icon: Icons.edit_document, title: 'Reports', route: '/reports', currentRoute: currentRoute),
          HoverListTile(icon: Icons.settings, title: 'Settings', route: '/settings', currentRoute: currentRoute),
        ],
      ),
    );
  }
}

class HoverListTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String route;
  final String currentRoute;

  const HoverListTile({super.key, required this.icon, required this.title, required this.route, required this.currentRoute});

  @override
  State<HoverListTile> createState() => _HoverListTileState();
}

class _HoverListTileState extends State<HoverListTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isActive = widget.currentRoute == widget.route;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        decoration: BoxDecoration(color: isActive ? const Color(0xFF1E282C) : (_isHovered ? const Color(0xFF1E282C) : Colors.transparent)),
        child: ListTile(
          leading: Icon(widget.icon, size: 26, color: isActive ? Colors.white : (_isHovered ? Colors.white : const Color(0xFFB8C7CE))),
          title: Text(widget.title, style: TextStyle(color: isActive ? Colors.white : (_isHovered ? Colors.white : const Color(0xFFB8C7CE)))),
          onTap: () {
            if (!isActive) context.go(widget.route);
          },
        ),
      ),
    );
  }
}
