import 'package:intl/intl.dart';

class Helpers {
  // Formater une date
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Formater une heure
  static String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  // Formater un montant d'argent
  static String formatCurrency(double amount) {
    return '${amount.toStringAsFixed(2)} €';
  }

  // Calculer les jours restants
  static int daysUntil(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(DateTime(now.year, now.month, now.day));
    return difference.inDays;
  }

  // Vérifier si une date est passée
  static bool isPastDue(DateTime date) {
    return DateTime.now().isAfter(date);
  }

  // Obtenir la couleur selon la priorité
  static String getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return '#DC2626';
      case 'important':
        return '#F59E0B';
      default:
        return '#10B981';
    }
  }

  // Calculer le coût mensuel d'un abonnement
  static double calculateMonthlyCost(double amount, String frequency) {
    switch (frequency.toLowerCase()) {
      case 'mensuel':
        return amount;
      case 'annuel':
        return amount / 12;
      case 'hebdomadaire':
        return amount * 4.33; // Moyenne de semaines par mois
      default:
        return amount;
    }
  }

  // Obtenir un message de motivation
  static String getMotivationalMessage(int progress) {
    if (progress >= 100) {
      return 'Plus Ultra ! Objectif accompli ! 🎉';
    } else if (progress >= 75) {
      return 'Presque là ! Continue comme ça ! 💪';
    } else if (progress >= 50) {
      return 'À mi-chemin ! Tu peux le faire ! 🔥';
    } else if (progress >= 25) {
      return 'Bon début ! Continue sur ta lancée ! 🚀';
    } else {
      return 'Chaque pas compte ! Go Beyond ! ⭐';
    }
  }

  // Valider un email
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  // Calculer la force d'un mot de passe
  static String getPasswordStrength(String password) {
    if (password.length < 6) return 'Faible';
    if (password.length < 10) return 'Moyen';
    if (password.length >= 10 && password.contains(RegExp(r'[A-Z]')) && password.contains(RegExp(r'[0-9]'))) {
      return 'Fort';
    }
    return 'Moyen';
  }
}
