import '../.dart_frog/kitchen_sink_client/lib/kitchen_sink_client.dart';

void main() async {
  final client = KitchenSinkClient.localhost();

  final response = await client.users$id.$name('1', 'felix').post();
  print(await response.body());

  client.close();
}
