import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math';

// Importa el BLoC de Ranking.
import '../bloc/repartidor_ranking/repartidor_ranking_bloc.dart';
// Importa el Enum Timeframe, UserRole Y la función stringToUserRole corregida.
import '../../utils/enums.dart';
import '../widgets/custom_drawer.dart';
import '../bloc/auth/auth_bloc.dart';

// *** IMPORTANTE: Se elimina la redefinición local de stringToUserRole, ***
// *** ya que debe importarse desde 'package:app_repartidor/utils/enums.dart'; ***
// *** Si el compilador lo requiere, añádela de nuevo usando 'show' o 'hide'. ***


class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {

  // Cuando se inicializa la pantalla, cargamos el ranking por defecto (Semana)
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Disparamos el evento inicial del ranking
      context.read<RepartidorRankingBloc>().add(
        const LoadRepartidorRanking(Timeframe.week),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // OBTENER ESTADO DE AUTENTICACIÓN PARA EL DRAWER (Utilizando context.watch)
    final authState = context.watch<AuthBloc>().state;
    String? userName;
    String? userEmail;
    UserRole userRole = UserRole.public; // Valor por defecto

    // LÓGICA DE ROL: Si el usuario está autenticado, establecemos el rol y la data.
    if (authState is AuthAuthenticated) {
      // *** CAMBIO CRÍTICO: USAMOS LA FUNCIÓN IMPORTADA DE enums.dart ***
      userRole = stringToUserRole(authState.userRole);
      final userRoleString = authState.userRole;

      // La data se sigue mostrando para Manager o Repartidor
      userName = '${userRoleString.toUpperCase()} ID: ${authState.userUid.substring(0, min(8, authState.userUid.length))}';
      userEmail = 'autenticado@deliveryapp.com';
    }


    return Scaffold(
      // El CustomDrawer recibe el rol determinado por el AuthBloc.
      drawer: CustomDrawer(
        role: userRole,
        userName: userName,
        userEmail: userEmail,
      ),

      appBar: AppBar(
        title: const Text('Ranking de Repartidores'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: BlocBuilder<RepartidorRankingBloc, RepartidorRankingState>(
        builder: (context, state) {
          // ... (Widgets de Ranking) ...
          return Column(
            children: [
              _buildTimeframeFilter(context, state.selectedTimeframe, theme),

              if (state.isLoading)
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                    child: CircularProgressIndicator(color: theme.colorScheme.primary),
                  ),
                ),

              if (state.error != null && !state.isLoading)
                _buildErrorState(state.error!, theme),

              if (!state.isLoading && state.ranking.isEmpty && state.error == null)
                _buildEmptyState(theme),

              if (!state.isLoading && state.ranking.isNotEmpty)
                Expanded(
                  child: _buildRankingList(state, theme),
                ),
            ],
          );
        },
      ),
    );
  }

  // --- Widgets Auxiliares (sin cambios, excepto que ahora usan la lógica de enums.dart) ---

  // (Resto de métodos auxiliares... omitidos para mantener el foco en la corrección)

  Widget _buildTimeframeFilter(BuildContext context, Timeframe selected, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      color: theme.colorScheme.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: Timeframe.values.map((timeframe) {
          final isSelected = timeframe == selected;
          return ChoiceChip(
            label: Text(
              _timeframeToString(timeframe),
              style: theme.textTheme.titleMedium?.copyWith(
                color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            selected: isSelected,
            selectedColor: theme.colorScheme.primary,
            onSelected: (bool selected) {
              if (selected && !context.read<RepartidorRankingBloc>().state.isLoading) {
                context.read<RepartidorRankingBloc>().add(
                  LoadRepartidorRanking(timeframe),
                );
              }
            },
          );
        }).toList(),
      ),
    );
  }

  String _timeframeToString(Timeframe timeframe) {
    switch (timeframe) {
      case Timeframe.today:
        return 'Hoy';
      case Timeframe.week:
        return 'Semana';
      case Timeframe.month:
        return 'Mes';
    }
  }

  Widget _buildRankingList(RepartidorRankingState state, ThemeData theme) {
    return ListView.builder(
      itemCount: state.ranking.length,
      itemBuilder: (context, index) {
        final entry = state.ranking[index];
        final rank = index + 1;

        Color rankColor;
        IconData rankIcon;

        if (rank == 1) {
          rankColor = Colors.amber.shade700;
          rankIcon = Icons.emoji_events; // Medalla de Oro
        } else if (rank == 2) {
          rankColor = Colors.grey.shade500;
          rankIcon = Icons.emoji_events; // Medalla de Plata
        } else if (rank == 3) {
          rankColor = Colors.brown.shade400;
          rankIcon = Icons.emoji_events; // Medalla de Bronce
        } else {
          rankColor = theme.colorScheme.onSurface.withOpacity(0.6);
          rankIcon = Icons.list;
        }

        // Generar un nombre corto para el UID
        final displayName = entry.nombreRepartidor ??
            'Repartidor ${entry.repartidorUid.substring(0, min(5, entry.repartidorUid.length))}';

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: ListTile(
            leading: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(rankIcon, color: rankColor, size: 28),
                Text('#$rank', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: rankColor)),
              ],
            ),
            title: Text(
              displayName,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              'ID: ${entry.repartidorUid.substring(0, min(8, entry.repartidorUid.length))}',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${entry.pedidosCompletados} entregas',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.leaderboard_outlined, size: 80, color: theme.colorScheme.primary.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text('Aún no hay entregas completadas.', style: theme.textTheme.headlineSmall),
            Text('¡Incentiva a tus repartidores!', style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          Icon(Icons.error, size: 60, color: Colors.red.shade700),
          const SizedBox(height: 10),
          Text('Error de Carga:', style: theme.textTheme.titleLarge),
          Text(error, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}