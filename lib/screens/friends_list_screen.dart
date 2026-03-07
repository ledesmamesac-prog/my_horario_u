import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/social_provider.dart';
import 'compare_schedules_screen.dart';

class FriendsListScreen extends StatefulWidget {
  const FriendsListScreen({super.key});

  @override
  State<FriendsListScreen> createState() => _FriendsListScreenState();
}

class _FriendsListScreenState extends State<FriendsListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<SocialProvider>().loadAmigos());
  }

  @override
  Widget build(BuildContext context) {
    final socialProvider = context.watch<SocialProvider>();
    final amigos = socialProvider.amigos;

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Amigos')),
      body: amigos.isEmpty
          ? const Center(child: Text('Aún no tienes amigos agregados.'))
          : ListView.builder(
              itemCount: amigos.length,
              itemBuilder: (context, index) {
                final amigo = amigos[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: amigo['fotoUrl'] != null 
                        ? NetworkImage(amigo['fotoUrl']) 
                        : null,
                    child: amigo['fotoUrl'] == null 
                        ? const Icon(Icons.person) 
                        : null,
                  ),
                  title: Text(amigo['nombre']),
                  subtitle: Text(amigo['email']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.compare_arrows_rounded, color: Colors.blue),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                        onPressed: () => _confirmDelete(context, socialProvider, amigo),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CompareSchedulesScreen(friend: amigo),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  void _confirmDelete(BuildContext context, SocialProvider provider, Map<String, dynamic> amigo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Amigo'),
        content: Text('¿Estás seguro de que quieres eliminar a ${amigo['nombre']} de tu lista?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              provider.removeAmigo(amigo['uid']);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${amigo['nombre']} eliminado.')),
              );
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
