import 'package:readiculous_frontend/app_bootstrap.dart';
import 'config/app_env.dart';

Future<void> main() async {
  await bootstrap(AppFlavor.prod);
}
