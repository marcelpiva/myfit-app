import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt'),
  ];

  /// No description provided for @appName.
  ///
  /// In pt, this message translates to:
  /// **'MyFit'**
  String get appName;

  /// No description provided for @welcome.
  ///
  /// In pt, this message translates to:
  /// **'Bem-vindo'**
  String get welcome;

  /// No description provided for @welcomeHeadline.
  ///
  /// In pt, this message translates to:
  /// **'Transforme seu\nnegócio fitness'**
  String get welcomeHeadline;

  /// No description provided for @welcomeSubheadline.
  ///
  /// In pt, this message translates to:
  /// **'Crie treinos, gerencie alunos e receba pagamentos em uma única plataforma.'**
  String get welcomeSubheadline;

  /// No description provided for @getStartedFree.
  ///
  /// In pt, this message translates to:
  /// **'Começar gratuitamente'**
  String get getStartedFree;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In pt, this message translates to:
  /// **'Já tenho uma conta'**
  String get alreadyHaveAccount;

  /// No description provided for @termsAgreement.
  ///
  /// In pt, this message translates to:
  /// **'Ao continuar, você concorda com os Termos de Uso'**
  String get termsAgreement;

  /// No description provided for @professionals.
  ///
  /// In pt, this message translates to:
  /// **'Profissionais'**
  String get professionals;

  /// No description provided for @students.
  ///
  /// In pt, this message translates to:
  /// **'Alunos'**
  String get students;

  /// No description provided for @rating.
  ///
  /// In pt, this message translates to:
  /// **'Avaliação'**
  String get rating;

  /// No description provided for @login.
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get login;

  /// No description provided for @signIn.
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get signIn;

  /// No description provided for @loginHeadline.
  ///
  /// In pt, this message translates to:
  /// **'Entrar na\nsua conta'**
  String get loginHeadline;

  /// No description provided for @loginSubheadline.
  ///
  /// In pt, this message translates to:
  /// **'Bem-vindo de volta'**
  String get loginSubheadline;

  /// No description provided for @welcomeBack.
  ///
  /// In pt, this message translates to:
  /// **'Bem-vindo\nde volta'**
  String get welcomeBack;

  /// No description provided for @loginSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Entre com suas credenciais para continuar'**
  String get loginSubtitle;

  /// No description provided for @dontHaveAccount.
  ///
  /// In pt, this message translates to:
  /// **'Não tem uma conta?'**
  String get dontHaveAccount;

  /// No description provided for @email.
  ///
  /// In pt, this message translates to:
  /// **'E-mail'**
  String get email;

  /// No description provided for @emailHint.
  ///
  /// In pt, this message translates to:
  /// **'seu@email.com'**
  String get emailHint;

  /// No description provided for @password.
  ///
  /// In pt, this message translates to:
  /// **'Senha'**
  String get password;

  /// No description provided for @passwordHint.
  ///
  /// In pt, this message translates to:
  /// **'••••••••'**
  String get passwordHint;

  /// No description provided for @forgotPassword.
  ///
  /// In pt, this message translates to:
  /// **'Esqueci a senha'**
  String get forgotPassword;

  /// No description provided for @continueWithGoogle.
  ///
  /// In pt, this message translates to:
  /// **'Continuar com Google'**
  String get continueWithGoogle;

  /// No description provided for @continueWithApple.
  ///
  /// In pt, this message translates to:
  /// **'Continuar com Apple'**
  String get continueWithApple;

  /// No description provided for @noAccount.
  ///
  /// In pt, this message translates to:
  /// **'Não tem uma conta?'**
  String get noAccount;

  /// No description provided for @register.
  ///
  /// In pt, this message translates to:
  /// **'Cadastrar'**
  String get register;

  /// No description provided for @or.
  ///
  /// In pt, this message translates to:
  /// **'ou'**
  String get or;

  /// No description provided for @registerHeadline.
  ///
  /// In pt, this message translates to:
  /// **'Criar sua\nconta'**
  String get registerHeadline;

  /// No description provided for @registerSubheadline.
  ///
  /// In pt, this message translates to:
  /// **'Preencha seus dados para começar'**
  String get registerSubheadline;

  /// No description provided for @fullName.
  ///
  /// In pt, this message translates to:
  /// **'Nome completo'**
  String get fullName;

  /// No description provided for @fullNameHint.
  ///
  /// In pt, this message translates to:
  /// **'Seu nome'**
  String get fullNameHint;

  /// No description provided for @createAccount.
  ///
  /// In pt, this message translates to:
  /// **'Criar conta'**
  String get createAccount;

  /// No description provided for @termsAccept.
  ///
  /// In pt, this message translates to:
  /// **'Li e aceito os '**
  String get termsAccept;

  /// No description provided for @termsOfUse.
  ///
  /// In pt, this message translates to:
  /// **'Termos de Uso'**
  String get termsOfUse;

  /// No description provided for @and.
  ///
  /// In pt, this message translates to:
  /// **' e '**
  String get and;

  /// No description provided for @privacyPolicy.
  ///
  /// In pt, this message translates to:
  /// **'Política de Privacidade'**
  String get privacyPolicy;

  /// No description provided for @haveAccount.
  ///
  /// In pt, this message translates to:
  /// **'Já tem uma conta?'**
  String get haveAccount;

  /// No description provided for @organizations.
  ///
  /// In pt, this message translates to:
  /// **'Organizações'**
  String get organizations;

  /// No description provided for @selectOrganization.
  ///
  /// In pt, this message translates to:
  /// **'Selecione uma organização para continuar'**
  String get selectOrganization;

  /// No description provided for @createOrganization.
  ///
  /// In pt, this message translates to:
  /// **'Criar organização'**
  String get createOrganization;

  /// No description provided for @joinWithCode.
  ///
  /// In pt, this message translates to:
  /// **'Entrar com código'**
  String get joinWithCode;

  /// No description provided for @inviteCode.
  ///
  /// In pt, this message translates to:
  /// **'Código de convite'**
  String get inviteCode;

  /// No description provided for @inviteCodeDescription.
  ///
  /// In pt, this message translates to:
  /// **'Digite o código fornecido pela organização'**
  String get inviteCodeDescription;

  /// No description provided for @inviteCodeHint.
  ///
  /// In pt, this message translates to:
  /// **'ABC123'**
  String get inviteCodeHint;

  /// No description provided for @cancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @join.
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get join;

  /// No description provided for @student.
  ///
  /// In pt, this message translates to:
  /// **'Aluno'**
  String get student;

  /// No description provided for @home.
  ///
  /// In pt, this message translates to:
  /// **'Início'**
  String get home;

  /// No description provided for @workouts.
  ///
  /// In pt, this message translates to:
  /// **'Treinos'**
  String get workouts;

  /// No description provided for @nutrition.
  ///
  /// In pt, this message translates to:
  /// **'Nutrição'**
  String get nutrition;

  /// No description provided for @progress.
  ///
  /// In pt, this message translates to:
  /// **'Progresso'**
  String get progress;

  /// No description provided for @profile.
  ///
  /// In pt, this message translates to:
  /// **'Perfil'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In pt, this message translates to:
  /// **'Configurações'**
  String get settings;

  /// No description provided for @logout.
  ///
  /// In pt, this message translates to:
  /// **'Sair'**
  String get logout;

  /// No description provided for @loading.
  ///
  /// In pt, this message translates to:
  /// **'Carregando...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In pt, this message translates to:
  /// **'Erro'**
  String get error;

  /// No description provided for @tryAgain.
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get tryAgain;

  /// No description provided for @save.
  ///
  /// In pt, this message translates to:
  /// **'Salvar'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In pt, this message translates to:
  /// **'Excluir'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In pt, this message translates to:
  /// **'Editar'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar'**
  String get add;

  /// No description provided for @search.
  ///
  /// In pt, this message translates to:
  /// **'Buscar'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In pt, this message translates to:
  /// **'Filtrar'**
  String get filter;

  /// No description provided for @sort.
  ///
  /// In pt, this message translates to:
  /// **'Ordenar'**
  String get sort;

  /// No description provided for @noResults.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum resultado encontrado'**
  String get noResults;

  /// No description provided for @success.
  ///
  /// In pt, this message translates to:
  /// **'Sucesso'**
  String get success;

  /// No description provided for @confirm.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar'**
  String get confirm;

  /// No description provided for @back.
  ///
  /// In pt, this message translates to:
  /// **'Voltar'**
  String get back;

  /// No description provided for @next.
  ///
  /// In pt, this message translates to:
  /// **'Próximo'**
  String get next;

  /// No description provided for @finish.
  ///
  /// In pt, this message translates to:
  /// **'Finalizar'**
  String get finish;

  /// No description provided for @close.
  ///
  /// In pt, this message translates to:
  /// **'Fechar'**
  String get close;

  /// No description provided for @create.
  ///
  /// In pt, this message translates to:
  /// **'Criar'**
  String get create;

  /// No description provided for @update.
  ///
  /// In pt, this message translates to:
  /// **'Atualizar'**
  String get update;

  /// No description provided for @select.
  ///
  /// In pt, this message translates to:
  /// **'Selecionar'**
  String get select;

  /// No description provided for @goalHypertrophy.
  ///
  /// In pt, this message translates to:
  /// **'Hipertrofia'**
  String get goalHypertrophy;

  /// No description provided for @goalStrength.
  ///
  /// In pt, this message translates to:
  /// **'Força'**
  String get goalStrength;

  /// No description provided for @goalFatLoss.
  ///
  /// In pt, this message translates to:
  /// **'Emagrecimento'**
  String get goalFatLoss;

  /// No description provided for @goalEndurance.
  ///
  /// In pt, this message translates to:
  /// **'Resistência'**
  String get goalEndurance;

  /// No description provided for @goalFunctional.
  ///
  /// In pt, this message translates to:
  /// **'Funcional'**
  String get goalFunctional;

  /// No description provided for @goalGeneralFitness.
  ///
  /// In pt, this message translates to:
  /// **'Condicionamento Geral'**
  String get goalGeneralFitness;

  /// No description provided for @difficultyBeginner.
  ///
  /// In pt, this message translates to:
  /// **'Iniciante'**
  String get difficultyBeginner;

  /// No description provided for @difficultyIntermediate.
  ///
  /// In pt, this message translates to:
  /// **'Intermediário'**
  String get difficultyIntermediate;

  /// No description provided for @difficultyAdvanced.
  ///
  /// In pt, this message translates to:
  /// **'Avançado'**
  String get difficultyAdvanced;

  /// No description provided for @muscleChest.
  ///
  /// In pt, this message translates to:
  /// **'Peito'**
  String get muscleChest;

  /// No description provided for @muscleBack.
  ///
  /// In pt, this message translates to:
  /// **'Costas'**
  String get muscleBack;

  /// No description provided for @muscleShoulders.
  ///
  /// In pt, this message translates to:
  /// **'Ombros'**
  String get muscleShoulders;

  /// No description provided for @muscleBiceps.
  ///
  /// In pt, this message translates to:
  /// **'Bíceps'**
  String get muscleBiceps;

  /// No description provided for @muscleTriceps.
  ///
  /// In pt, this message translates to:
  /// **'Tríceps'**
  String get muscleTriceps;

  /// No description provided for @muscleLegs.
  ///
  /// In pt, this message translates to:
  /// **'Pernas'**
  String get muscleLegs;

  /// No description provided for @muscleGlutes.
  ///
  /// In pt, this message translates to:
  /// **'Glúteos'**
  String get muscleGlutes;

  /// No description provided for @muscleAbs.
  ///
  /// In pt, this message translates to:
  /// **'Abdômen'**
  String get muscleAbs;

  /// No description provided for @muscleCardio.
  ///
  /// In pt, this message translates to:
  /// **'Cardio'**
  String get muscleCardio;

  /// No description provided for @muscleFullBody.
  ///
  /// In pt, this message translates to:
  /// **'Corpo Inteiro'**
  String get muscleFullBody;

  /// No description provided for @techniqueNormal.
  ///
  /// In pt, this message translates to:
  /// **'Normal'**
  String get techniqueNormal;

  /// No description provided for @techniqueSuperset.
  ///
  /// In pt, this message translates to:
  /// **'Super-Set'**
  String get techniqueSuperset;

  /// No description provided for @techniqueBiset.
  ///
  /// In pt, this message translates to:
  /// **'Bi-Set'**
  String get techniqueBiset;

  /// No description provided for @techniqueTriset.
  ///
  /// In pt, this message translates to:
  /// **'Tri-Set'**
  String get techniqueTriset;

  /// No description provided for @techniqueGiantset.
  ///
  /// In pt, this message translates to:
  /// **'Giant Set'**
  String get techniqueGiantset;

  /// No description provided for @techniqueDropset.
  ///
  /// In pt, this message translates to:
  /// **'Drop Set'**
  String get techniqueDropset;

  /// No description provided for @techniqueRestPause.
  ///
  /// In pt, this message translates to:
  /// **'Rest Pause'**
  String get techniqueRestPause;

  /// No description provided for @techniqueCluster.
  ///
  /// In pt, this message translates to:
  /// **'Cluster'**
  String get techniqueCluster;

  /// No description provided for @session.
  ///
  /// In pt, this message translates to:
  /// **'Sessão'**
  String get session;

  /// No description provided for @newSession.
  ///
  /// In pt, this message translates to:
  /// **'Nova Sessão'**
  String get newSession;

  /// No description provided for @createSession.
  ///
  /// In pt, this message translates to:
  /// **'Criar Sessão'**
  String get createSession;

  /// No description provided for @editSession.
  ///
  /// In pt, this message translates to:
  /// **'Editar Sessão'**
  String get editSession;

  /// No description provided for @cancelSession.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar Sessão'**
  String get cancelSession;

  /// No description provided for @rescheduleSession.
  ///
  /// In pt, this message translates to:
  /// **'Reagendar Sessão'**
  String get rescheduleSession;

  /// No description provided for @sessionCreated.
  ///
  /// In pt, this message translates to:
  /// **'Sessão criada'**
  String get sessionCreated;

  /// No description provided for @sessionConfirmed.
  ///
  /// In pt, this message translates to:
  /// **'Sessão confirmada'**
  String get sessionConfirmed;

  /// No description provided for @sessionCanceled.
  ///
  /// In pt, this message translates to:
  /// **'Sessão cancelada'**
  String get sessionCanceled;

  /// No description provided for @sessionRescheduled.
  ///
  /// In pt, this message translates to:
  /// **'Sessão reagendada'**
  String get sessionRescheduled;

  /// No description provided for @groupSession.
  ///
  /// In pt, this message translates to:
  /// **'Sessão em Grupo'**
  String get groupSession;

  /// No description provided for @recurringSession.
  ///
  /// In pt, this message translates to:
  /// **'Sessão Recorrente'**
  String get recurringSession;

  /// No description provided for @duration.
  ///
  /// In pt, this message translates to:
  /// **'Duração'**
  String get duration;

  /// No description provided for @start.
  ///
  /// In pt, this message translates to:
  /// **'Início'**
  String get start;

  /// No description provided for @end.
  ///
  /// In pt, this message translates to:
  /// **'Fim'**
  String get end;

  /// No description provided for @date.
  ///
  /// In pt, this message translates to:
  /// **'Data'**
  String get date;

  /// No description provided for @time.
  ///
  /// In pt, this message translates to:
  /// **'Horário'**
  String get time;

  /// No description provided for @exercise.
  ///
  /// In pt, this message translates to:
  /// **'Exercício'**
  String get exercise;

  /// No description provided for @exercises.
  ///
  /// In pt, this message translates to:
  /// **'Exercícios'**
  String get exercises;

  /// No description provided for @sets.
  ///
  /// In pt, this message translates to:
  /// **'Séries'**
  String get sets;

  /// No description provided for @reps.
  ///
  /// In pt, this message translates to:
  /// **'Repetições'**
  String get reps;

  /// No description provided for @rest.
  ///
  /// In pt, this message translates to:
  /// **'Descanso'**
  String get rest;

  /// No description provided for @weight.
  ///
  /// In pt, this message translates to:
  /// **'Peso'**
  String get weight;

  /// No description provided for @monday.
  ///
  /// In pt, this message translates to:
  /// **'Segunda'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In pt, this message translates to:
  /// **'Terça'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In pt, this message translates to:
  /// **'Quarta'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In pt, this message translates to:
  /// **'Quinta'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In pt, this message translates to:
  /// **'Sexta'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In pt, this message translates to:
  /// **'Sábado'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In pt, this message translates to:
  /// **'Domingo'**
  String get sunday;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
