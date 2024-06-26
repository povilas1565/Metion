import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:metion/Logic/AdminLogic/adminBloc.dart';
import 'package:metion/Logic/Authentication/authBloc.dart';
import 'package:metion/Logic/Authentication/authState.dart';
import 'package:metion/Logic/BookingLogic/bookingBloc.dart';
import 'package:metion/Logic/DriverLogic/driverBloc.dart';
import 'package:metion/Logic/ProviderViewModel/userNotifier.dart';
import 'package:metion/Logic/UsersLogic/userBloc.dart';
import 'package:metion/Presentation/Commons/colors.dart';
import 'package:metion/Presentation/Commons/strings.dart';
import 'package:metion/Presentation/Routes/router.dart';
import 'package:metion/Presentation/themes/light_themes.dart';
import 'package:metion/Presentation/utils/secrets.dart';
import 'package:metion/Providers/bookingProviders.dart';
import 'package:metion/Providers/driverProvider.dart';
import 'package:metion/Providers/userProvider.dart';
import 'package:metion/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PaystackPlugin().initialize(publicKey: testPublicKey);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp( MyApp(router: AppRouter(),));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key, required this.router}) : super(key: key);
  final AppRouter router;
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    /* Sets the statusBar colour of the app */
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: kOrangeColor,
      ),
    );
    return MultiBlocProvider(
      providers: [
        BlocProvider<BookingBloc>(create: (context) => BookingBloc()),
        BlocProvider<AuthBloc>(create: (context) => AuthBloc()),
        BlocProvider<DriversBloc>(create: (context) => DriversBloc()),
        BlocProvider<UserBloc>(create: (context) => UserBloc()),
        BlocProvider<AdminBloc>(create: (context) => AdminBloc()),

      ],
      // create: (context) {
      //   return AuthBloc()..add(AuthInit());
      //
      // },
      child: ScreenUtilInit(
        designSize: const Size(360, 740),
        builder: (BuildContext context, child) =>
    MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => BookingProvider()),
      ChangeNotifierProvider(create: (_) => UserProvider()),
      ChangeNotifierProvider(create: (_) => DriverProvider()),
      ChangeNotifierProvider(create: (_) => UserNotifier()),
    ],
           child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: kAppTitle,
          theme: CustomTheme.lightTheme(),

            builder: (context, child) {
              return BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  return BlocListener<AuthBloc, AuthState>(
                    listener: (context, state) async {
                      if (state is AuthNotAuthenticated) {
                        //Navigator.pushNamedAndRemoveUntil(context, loginPage, (route) => false);
                        //Navigator.pushNamed(context, loginPage);
                      }

                      if (state is AuthGetUser || state is AuthAuthenticated) {

                        await AuthBloc().onGettingUserRequested(context);
                        await BookingBloc().onBookingRequirementsRequested(context);
                        await UserBloc().onSavingNotification();
                      }

                    },
                    child: child,

                  );
                },
              );
            },
          onGenerateRoute: router.generateRoute,

        ),
      )),
    );


  }

}




