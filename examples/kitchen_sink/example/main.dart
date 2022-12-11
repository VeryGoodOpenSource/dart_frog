import 'package:kitchen_sink_client/kitchen_sink_client.dart';

void main() async {
  final client = KitchenSinkClient.localhost();

  final response = await client.usersById('1').byName('Felix').get();
  print(response.statusCode);
  print(await response.body());

  client.close();
}
