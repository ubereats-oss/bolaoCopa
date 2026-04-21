@echo off

echo import 'package:flutter/material.dart'; > lib\features\auth\login_screen.dart
echo class LoginScreen extends StatelessWidget { >> lib\features\auth\login_screen.dart
echo   const LoginScreen({super.key}); >> lib\features\auth\login_screen.dart
echo   @override >> lib\features\auth\login_screen.dart
echo   Widget build(BuildContext context) =^> const Scaffold(body: Center(child: Text('Login'))); >> lib\features\auth\login_screen.dart
echo } >> lib\features\auth\login_screen.dart

echo import 'package:flutter/material.dart'; > lib\features\auth\register_screen.dart
echo class RegisterScreen extends StatelessWidget { >> lib\features\auth\register_screen.dart
echo   const RegisterScreen({super.key}); >> lib\features\auth\register_screen.dart
echo   @override >> lib\features\auth\register_screen.dart
echo   Widget build(BuildContext context) =^> const Scaffold(body: Center(child: Text('Registro'))); >> lib\features\auth\register_screen.dart
echo } >> lib\features\auth\register_screen.dart

echo import 'package:flutter/material.dart'; > lib\features\home\home_screen.dart
echo class HomeScreen extends StatelessWidget { >> lib\features\home\home_screen.dart
echo   const HomeScreen({super.key}); >> lib\features\home\home_screen.dart
echo   @override >> lib\features\home\home_screen.dart
echo   Widget build(BuildContext context) =^> const Scaffold(body: Center(child: Text('Home'))); >> lib\features\home\home_screen.dart
echo } >> lib\features\home\home_screen.dart

echo import 'package:flutter/material.dart'; > lib\features\matches\matches_screen.dart
echo class MatchesScreen extends StatelessWidget { >> lib\features\matches\matches_screen.dart
echo   const MatchesScreen({super.key}); >> lib\features\matches\matches_screen.dart
echo   @override >> lib\features\matches\matches_screen.dart
echo   Widget build(BuildContext context) =^> const Scaffold(body: Center(child: Text('Jogos'))); >> lib\features\matches\matches_screen.dart
echo } >> lib\features\matches\matches_screen.dart

echo import 'package:flutter/material.dart'; > lib\features\matches\match_prediction_screen.dart
echo class MatchPredictionScreen extends StatelessWidget { >> lib\features\matches\match_prediction_screen.dart
echo   const MatchPredictionScreen({super.key}); >> lib\features\matches\match_prediction_screen.dart
echo   @override >> lib\features\matches\match_prediction_screen.dart
echo   Widget build(BuildContext context) =^> const Scaffold(body: Center(child: Text('Palpite'))); >> lib\features\matches\match_prediction_screen.dart
echo } >> lib\features\matches\match_prediction_screen.dart

echo import 'package:flutter/material.dart'; > lib\features\ranking\ranking_screen.dart
echo class RankingScreen extends StatelessWidget { >> lib\features\ranking\ranking_screen.dart
echo   const RankingScreen({super.key}); >> lib\features\ranking\ranking_screen.dart
echo   @override >> lib\features\ranking\ranking_screen.dart
echo   Widget build(BuildContext context) =^> const Scaffold(body: Center(child: Text('Ranking'))); >> lib\features\ranking\ranking_screen.dart
echo } >> lib\features\ranking\ranking_screen.dart

echo import 'package:flutter/material.dart'; > lib\features\extras\extra_predictions_screen.dart
echo class ExtraPredictionsScreen extends StatelessWidget { >> lib\features\extras\extra_predictions_screen.dart
echo   const ExtraPredictionsScreen({super.key}); >> lib\features\extras\extra_predictions_screen.dart
echo   @override >> lib\features\extras\extra_predictions_screen.dart
echo   Widget build(BuildContext context) =^> const Scaffold(body: Center(child: Text('Extras'))); >> lib\features\extras\extra_predictions_screen.dart
echo } >> lib\features\extras\extra_predictions_screen.dart

echo import 'package:flutter/material.dart'; > lib\features\admin\admin_dashboard.dart
echo class AdminDashboard extends StatelessWidget { >> lib\features\admin\admin_dashboard.dart
echo   const AdminDashboard({super.key}); >> lib\features\admin\admin_dashboard.dart
echo   @override >> lib\features\admin\admin_dashboard.dart
echo   Widget build(BuildContext context) =^> const Scaffold(body: Center(child: Text('Admin'))); >> lib\features\admin\admin_dashboard.dart
echo } >> lib\features\admin\admin_dashboard.dart

echo import 'package:flutter/material.dart'; > lib\features\admin\manage_matches_screen.dart
echo class ManageMatchesScreen extends StatelessWidget { >> lib\features\admin\manage_matches_screen.dart
echo   const ManageMatchesScreen({super.key}); >> lib\features\admin\manage_matches_screen.dart
echo   @override >> lib\features\admin\manage_matches_screen.dart
echo   Widget build(BuildContext context) =^> const Scaffold(body: Center(child: Text('Gerenciar Jogos'))); >> lib\features\admin\manage_matches_screen.dart
echo } >> lib\features\admin\manage_matches_screen.dart

echo import 'package:flutter/material.dart'; > lib\features\admin\manage_results_screen.dart
echo class ManageResultsScreen extends StatelessWidget { >> lib\features\admin\manage_results_screen.dart
echo   const ManageResultsScreen({super.key}); >> lib\features\admin\manage_results_screen.dart
echo   @override >> lib\features\admin\manage_results_screen.dart
echo   Widget build(BuildContext context) =^> const Scaffold(body: Center(child: Text('Gerenciar Resultados'))); >> lib\features\admin\manage_results_screen.dart
echo } >> lib\features\admin\manage_results_screen.dart

echo Telas preenchidas com sucesso!