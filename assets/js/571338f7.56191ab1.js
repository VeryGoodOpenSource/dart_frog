"use strict";(self.webpackChunkdart_frog_docs=self.webpackChunkdart_frog_docs||[]).push([[260],{3905:(e,t,n)=>{n.d(t,{Zo:()=>p,kt:()=>k});var a=n(7294);function r(e,t,n){return t in e?Object.defineProperty(e,t,{value:n,enumerable:!0,configurable:!0,writable:!0}):e[t]=n,e}function o(e,t){var n=Object.keys(e);if(Object.getOwnPropertySymbols){var a=Object.getOwnPropertySymbols(e);t&&(a=a.filter((function(t){return Object.getOwnPropertyDescriptor(e,t).enumerable}))),n.push.apply(n,a)}return n}function i(e){for(var t=1;t<arguments.length;t++){var n=null!=arguments[t]?arguments[t]:{};t%2?o(Object(n),!0).forEach((function(t){r(e,t,n[t])})):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(n)):o(Object(n)).forEach((function(t){Object.defineProperty(e,t,Object.getOwnPropertyDescriptor(n,t))}))}return e}function l(e,t){if(null==e)return{};var n,a,r=function(e,t){if(null==e)return{};var n,a,r={},o=Object.keys(e);for(a=0;a<o.length;a++)n=o[a],t.indexOf(n)>=0||(r[n]=e[n]);return r}(e,t);if(Object.getOwnPropertySymbols){var o=Object.getOwnPropertySymbols(e);for(a=0;a<o.length;a++)n=o[a],t.indexOf(n)>=0||Object.prototype.propertyIsEnumerable.call(e,n)&&(r[n]=e[n])}return r}var c=a.createContext({}),s=function(e){var t=a.useContext(c),n=t;return e&&(n="function"==typeof e?e(t):i(i({},t),e)),n},p=function(e){var t=s(e.components);return a.createElement(c.Provider,{value:t},e.children)},d={inlineCode:"code",wrapper:function(e){var t=e.children;return a.createElement(a.Fragment,{},t)}},u=a.forwardRef((function(e,t){var n=e.components,r=e.mdxType,o=e.originalType,c=e.parentName,p=l(e,["components","mdxType","originalType","parentName"]),u=s(n),k=r,h=u["".concat(c,".").concat(k)]||u[k]||d[k]||o;return n?a.createElement(h,i(i({ref:t},p),{},{components:n})):a.createElement(h,i({ref:t},p))}));function k(e,t){var n=arguments,r=t&&t.mdxType;if("string"==typeof e||r){var o=n.length,i=new Array(o);i[0]=u;var l={};for(var c in t)hasOwnProperty.call(t,c)&&(l[c]=t[c]);l.originalType=e,l.mdxType="string"==typeof e?e:r,i[1]=l;for(var s=2;s<o;s++)i[s]=n[s];return a.createElement.apply(null,i)}return a.createElement.apply(null,n)}u.displayName="MDXCreateElement"},4104:(e,t,n)=>{n.r(t),n.d(t,{assets:()=>c,contentTitle:()=>i,default:()=>d,frontMatter:()=>o,metadata:()=>l,toc:()=>s});var a=n(7462),r=(n(7294),n(3905));const o={sidebar_position:5,title:"\ud83d\udd0c WebSocket Counter",description:'Build a real time "Counter" powered by WebSockets.'},i="WebSocket Counter \ud83d\udd0c",l={unversionedId:"tutorials/web_socket_counter",id:"tutorials/web_socket_counter",title:"\ud83d\udd0c WebSocket Counter",description:'Build a real time "Counter" powered by WebSockets.',source:"@site/docs/tutorials/web_socket_counter.md",sourceDirName:"tutorials",slug:"/tutorials/web_socket_counter",permalink:"/docs/tutorials/web_socket_counter",draft:!1,editUrl:"https://github.com/VeryGoodOpenSource/dart_frog/tree/main/docs/docs/tutorials/web_socket_counter.md",tags:[],version:"current",sidebarPosition:5,frontMatter:{sidebar_position:5,title:"\ud83d\udd0c WebSocket Counter",description:'Build a real time "Counter" powered by WebSockets.'},sidebar:"docs",previous:{title:"\ud83d\uddd2 Todos",permalink:"/docs/tutorials/todos"},next:{title:"Deploy",permalink:"/docs/category/deploy"}},c={},s=[{value:"Overview",id:"overview",level:2},{value:"Creating a new app",id:"creating-a-new-app",level:2},{value:"Running the development server",id:"running-the-development-server",level:2},{value:"Creating the WebSocket Route",id:"creating-the-websocket-route",level:2},{value:"Adding a WebSocket Handler",id:"adding-a-websocket-handler",level:2},{value:"Establishing a WebSocket Connection",id:"establishing-a-websocket-connection",level:2},{value:"Managing the Counter State",id:"managing-the-counter-state",level:2},{value:"Providing the Counter",id:"providing-the-counter",level:2},{value:"Using the Counter",id:"using-the-counter",level:2}],p={toc:s};function d(e){let{components:t,...n}=e;return(0,r.kt)("wrapper",(0,a.Z)({},p,n,{components:t,mdxType:"MDXLayout"}),(0,r.kt)("h1",{id:"websocket-counter-"},"WebSocket Counter \ud83d\udd0c"),(0,r.kt)("admonition",{type:"info"},(0,r.kt)("p",{parentName:"admonition"},(0,r.kt)("strong",{parentName:"p"},"Difficulty"),": \ud83d\udfe0 Intermediate",(0,r.kt)("br",null),"\n",(0,r.kt)("strong",{parentName:"p"},"Length"),": 30 minutes"),(0,r.kt)("p",{parentName:"admonition"},"Before getting started, ",(0,r.kt)("a",{parentName:"p",href:"/docs/overview#prerequisites"},"read the Dart Frog prerequisites")," to make sure your development environment is ready.")),(0,r.kt)("h2",{id:"overview"},"Overview"),(0,r.kt)("p",null,"In this tutorial, we're going to build an app that exposes a single endpoint which handles WebSocket connections and maintains a real-time counter which can be incremented and decremented by connected clients."),(0,r.kt)("p",null,"When we're done, we should be able to connect to the ",(0,r.kt)("inlineCode",{parentName:"p"},"/ws")," endpoint and send or receive messages."),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-dart"},"import 'package:web_socket_channel/web_socket_channel.dart';\n\nvoid main() async {\n  final channel = WebSocketChannel.connect(Uri.parse('ws://localhost:8080/ws'));\n  channel.stream.listen(print);\n\n  channel.sink.add('__increment__');\n  channel.sink.add('__decrement__');\n\n  channel.sink.close();\n}\n")),(0,r.kt)("p",null,"We should see the following output:"),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre"},"0 # initial\n1 # increment\n0 # decrement\n")),(0,r.kt)("h2",{id:"creating-a-new-app"},"Creating a new app"),(0,r.kt)("p",null,"To create a new Dart Frog app, open your terminal, change to the directory where you'd like to create the app, and run the following command:"),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-bash"},"dart_frog create web_socket_counter\n")),(0,r.kt)("p",null,"You should see an output similar to:"),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre"},"\u2713 Creating web_socket_counter (0.1s)\n\u2713 Installing dependencies (1.7s)\n\nCreated web_socket_counter at ./web_socket_counter.\n\nGet started by typing:\n\ncd ./web_socket_counter\ndart_frog dev\n")),(0,r.kt)("h2",{id:"running-the-development-server"},"Running the development server"),(0,r.kt)("p",null,"You should now have a directory called ",(0,r.kt)("inlineCode",{parentName:"p"},"web_socket_counter"),". Let's change directories into the newly created project:"),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-bash"},"cd web_socket_counter\n")),(0,r.kt)("p",null,"Then, run the following command:"),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-bash"},"dart_frog dev\n")),(0,r.kt)("p",null,"This will start the development server on port ",(0,r.kt)("inlineCode",{parentName:"p"},"8080"),":"),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre"},"\u2713 Running on http://localhost:8080 (1.3s)\nThe Dart VM service is listening on http://127.0.0.1:8181/YKEF_nbwOpM=/\nThe Dart DevTools debugger and profiler is available at: http://127.0.0.1:8181/YKEF_nbwOpM=/devtools/#/?uri=ws%3A%2F%2F127.0.0.1%3A8181%2FYKEF_nbwOpM%3D%2Fws\n[hotreload] Hot reload is enabled.\n")),(0,r.kt)("p",null,"Make sure it's working by opening ",(0,r.kt)("a",{parentName:"p",href:"http://localhost:8080"},"http://localhost:8080")," in your browser or via ",(0,r.kt)("inlineCode",{parentName:"p"},"cURL"),":"),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-bash"},"curl --request GET \\\n  --url http://localhost:8080\n")),(0,r.kt)("p",null,"If everything succeeded, you should see ",(0,r.kt)("inlineCode",{parentName:"p"},"Welcome to Dart Frog!"),"."),(0,r.kt)("h2",{id:"creating-the-websocket-route"},"Creating the WebSocket Route"),(0,r.kt)("p",null,"Now that we have a running application, let's start by creating a new ",(0,r.kt)("inlineCode",{parentName:"p"},"ws")," route at ",(0,r.kt)("inlineCode",{parentName:"p"},"routes/ws.dart"),":"),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-dart"},"import 'package:dart_frog/dart_frog.dart';\n\nResponse onRequest(RequestContext context) {\n  return Response(body: 'You have requested /ws');\n}\n")),(0,r.kt)("p",null,"We can also delete the root endpoint at ",(0,r.kt)("inlineCode",{parentName:"p"},"routes/index.dart")," since we won't be needing it for this example."),(0,r.kt)("p",null,"Save the changes and hot reload should kick in \u26a1\ufe0f"),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre"},"[hotreload] - Application reloaded.\n")),(0,r.kt)("p",null,"Now if we visit ",(0,r.kt)("a",{parentName:"p",href:"http://localhost:8080/ws"},"http://localhost:8080/ws")," in the browser or via ",(0,r.kt)("inlineCode",{parentName:"p"},"cURL"),":"),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-bash"},"curl --request GET \\\n  --url http://localhost:8080\n")),(0,r.kt)("p",null,"We should see our new response:"),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre"},"You have requested /ws\n")),(0,r.kt)("h2",{id:"adding-a-websocket-handler"},"Adding a WebSocket Handler"),(0,r.kt)("p",null,"Next, we need to upgrade our route handler to handle WebSocket connections. To do this we'll use the ",(0,r.kt)("a",{parentName:"p",href:"https://pub.dev/packages/dart_frog_web_socket"},"dart_frog_web_socket")," package."),(0,r.kt)("p",null,"Add the ",(0,r.kt)("inlineCode",{parentName:"p"},"dart_frog_web_socket")," dependency:"),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre"},"dart pub add dart_frog_web_socket\n")),(0,r.kt)("p",null,"Now, let's update our route handler at ",(0,r.kt)("inlineCode",{parentName:"p"},"routes/ws.dart")," to use the provided ",(0,r.kt)("inlineCode",{parentName:"p"},"webSocketHandler")," from ",(0,r.kt)("inlineCode",{parentName:"p"},"dart_frog_web_socket"),":"),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-dart"},"import 'package:dart_frog/dart_frog.dart';\nimport 'package:dart_frog_web_socket/dart_frog_web_socket.dart';\n\nFuture<Response> onRequest(RequestContext context) async {\n  final handler = webSocketHandler(\n    (channel, protocol) {\n      // A new client has connected to our server.\n      print('connected');\n\n      // Send a message to the client.\n      channel.sink.add('hello from the server');\n\n      // Listen for messages from the client.\n      channel.stream.listen(\n        print,\n        // The client has disconnected.\n        onDone: () => print('disconnected'),\n      );\n    },\n  );\n\n  return handler(context);\n}\n")),(0,r.kt)("admonition",{type:"info"},(0,r.kt)("p",{parentName:"admonition"},"For more information, refer to the ",(0,r.kt)("a",{parentName:"p",href:"/docs/advanced/web_socket"},"WebSocket documentation"),".")),(0,r.kt)("p",null,"Save the changes and hot reload should kick in \u26a1\ufe0f"),(0,r.kt)("p",null,"Now we should be able to write a simple script to test the WebSocket connection."),(0,r.kt)("h2",{id:"establishing-a-websocket-connection"},"Establishing a WebSocket Connection"),(0,r.kt)("p",null,"Create a new directory called ",(0,r.kt)("inlineCode",{parentName:"p"},"example")," at the project root and create a ",(0,r.kt)("inlineCode",{parentName:"p"},"pubspec.yaml"),":"),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-yaml"},"name: example\npublish_to: none\n\nenvironment:\n  sdk: '>=2.18.0 <3.0.0'\n\ndependencies:\n  web_socket_channel: ^2.0.0\n")),(0,r.kt)("p",null,"Next, install the dependencies:"),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-sh"},"dart pub get\n")),(0,r.kt)("p",null,"Now, create a ",(0,r.kt)("inlineCode",{parentName:"p"},"main.dart")," with the following contents:"),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-dart"},"import 'package:web_socket_channel/web_socket_channel.dart';\n\nvoid main() {\n  // Connect to the remote WebSocket endpoint.\n  final uri = Uri.parse('ws://localhost:8080/ws');\n  final channel = WebSocketChannel.connect(uri);\n\n  // Listen to messages from the server.\n  channel.stream.listen(print);\n\n  // Send a message to the server.\n  channel.sink.add('hello from the client');\n\n  // Close the connection.\n  channel.sink.close();\n}\n")),(0,r.kt)("p",null,"We're using ",(0,r.kt)("a",{parentName:"p",href:"https://pub.dev/packages/web_socket_channel"},(0,r.kt)("inlineCode",{parentName:"a"},"package:web_socket_channel"))," to connect to our Dart Frog ",(0,r.kt)("inlineCode",{parentName:"p"},"/ws")," endpoint. We can send messages to the server by calling ",(0,r.kt)("inlineCode",{parentName:"p"},"add")," on the ",(0,r.kt)("inlineCode",{parentName:"p"},"WebSocketChannel")," sink. We can listen to incoming messages by subscribing to the ",(0,r.kt)("inlineCode",{parentName:"p"},"WebSocketChannel")," stream."),(0,r.kt)("p",null,"With the Dart Frog server still running, open a separate terminal, and run the example script:"),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-bash"},"dart example/main.dart\n")),(0,r.kt)("p",null,"We should see the following output on the client:"),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre"},"hello from the server\n")),(0,r.kt)("p",null,"On the server we should see the following output:"),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre"},"connected\nhello from the client\ndisconnected\n")),(0,r.kt)("p",null,"Awesome! We've configured a WebSocket handler and established a connection to our server \ud83c\udf89"),(0,r.kt)("h2",{id:"managing-the-counter-state"},"Managing the Counter State"),(0,r.kt)("p",null,"Now that we've configured the WebSocket handler, we're going to shift gears and work on creating a component that will manage the state of the counter."),(0,r.kt)("p",null,"In this example, we're going to use a cubit from the ",(0,r.kt)("a",{parentName:"p",href:"https://bloclibrary.dev"},"Bloc Library")," to manage the state of our counter because it provides a reactive API which allows us to stream state changes and query the current state at any given point in time. We're going to use ",(0,r.kt)("a",{parentName:"p",href:"https://pub.dev/packages/broadcast_bloc"},"package:broadcast_bloc")," which allows blocs or cubits to broadcast their state changes to any subscribed stream channels \u2014 this will come in handy later on."),(0,r.kt)("p",null,"Let's add the ",(0,r.kt)("inlineCode",{parentName:"p"},"broadcast_bloc")," dependency:"),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre"},"dart pub add broadcast_bloc\n")),(0,r.kt)("p",null,"Then, create a cubit in ",(0,r.kt)("inlineCode",{parentName:"p"},"lib/counter/cubit/counter_cubit.dart"),"."),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-dart"},"import 'package:broadcast_bloc/broadcast_bloc.dart';\n\nclass CounterCubit extends BroadcastCubit<int> {\n  // Create an instance with an initial state of 0.\n  CounterCubit() : super(0);\n\n  // Increment the current state.\n  void increment() => emit(state + 1);\n\n  // Decrement the current state.\n  void decrement() => emit(state - 1);\n}\n")),(0,r.kt)("p",null,"In order to access the cubit from our route handler, we'll create a ",(0,r.kt)("inlineCode",{parentName:"p"},"provider")," in ",(0,r.kt)("inlineCode",{parentName:"p"},"lib/counter/middleware/counter_provider.dart"),"."),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-dart"},"import 'package:dart_frog/dart_frog.dart';\nimport 'package:web_socket_counter/counter/counter.dart';\n\nfinal _counter = CounterCubit();\n\n// Provide the counter instance via `RequestContext`.\nfinal counterProvider = provider<CounterCubit>((_) => _counter);\n")),(0,r.kt)("admonition",{type:"info"},(0,r.kt)("p",{parentName:"admonition"},"For more information, refer to the ",(0,r.kt)("a",{parentName:"p",href:"/docs/basics/dependency-injection"},"dependency injection documentation"),".")),(0,r.kt)("p",null,"Let's also create a barrel file which exports all ",(0,r.kt)("inlineCode",{parentName:"p"},"counter")," components in ",(0,r.kt)("inlineCode",{parentName:"p"},"lib/counter/counter.dart"),":"),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-dart"},"export 'cubit/counter_cubit.dart';\nexport 'middleware/counter_provider.dart';\n")),(0,r.kt)("h2",{id:"providing-the-counter"},"Providing the Counter"),(0,r.kt)("p",null,"We need to use the ",(0,r.kt)("inlineCode",{parentName:"p"},"counterProvider")," in order to have access to it in nested. Create a global piece of middleware (",(0,r.kt)("inlineCode",{parentName:"p"},"routes/_middleware.dart"),"):"),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-dart"},"import 'package:dart_frog/dart_frog.dart';\nimport 'package:web_socket_counter/counter/counter.dart';\n\nHandler middleware(Handler handler) => handler.use(counterProvider);\n")),(0,r.kt)("admonition",{type:"info"},(0,r.kt)("p",{parentName:"admonition"},"For more information, refer to the ",(0,r.kt)("a",{parentName:"p",href:"/docs/basics/middleware"},"middleware documentation"),".")),(0,r.kt)("h2",{id:"using-the-counter"},"Using the Counter"),(0,r.kt)("p",null,"We can access the ",(0,r.kt)("inlineCode",{parentName:"p"},"CounterCubit")," instance from our WebSocket handler via ",(0,r.kt)("inlineCode",{parentName:"p"},"context.read<CounterCubit>()"),"."),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-dart"},"import 'package:dart_frog/dart_frog.dart';\nimport 'package:dart_frog_web_socket/dart_frog_web_socket.dart';\nimport 'package:web_socket_counter/counter/counter.dart';\n\nFuture<Response> onRequest(RequestContext context) async {\n  final handler = webSocketHandler(\n    (channel, protocol) {\n      // A new client has connected to our server.\n      // Subscribe the new client to receive notifications\n      // whenever the cubit state changes.\n      final cubit = context.read<CounterCubit>()..subscribe(channel);\n\n      // Send the current count to the new client.\n      channel.sink.add('${cubit.state}');\n\n      // Listen for messages from the client.\n      channel.stream.listen(\n        (event) {\n          switch (event) {\n            // Handle an increment message.\n            case '__increment__':\n              cubit.increment();\n              break;\n            // Handle a decrement message.\n            case '__decrement__':\n              cubit.decrement();\n              break;\n            // Ignore any other messages.\n            default:\n              break;\n          }\n        },\n        // The client has disconnected.\n        // Unsubscribe the channel.\n        onDone: () => cubit.unsubscribe(channel),\n      );\n    },\n  );\n\n  return handler(context);\n}\n")),(0,r.kt)("p",null,"First, we subscribe the newly connected client to the ",(0,r.kt)("inlineCode",{parentName:"p"},"CounterCubit")," in order to receive updates whenever the cubit state changes."),(0,r.kt)("p",null,"Next, we send the current count to the new client via ",(0,r.kt)("inlineCode",{parentName:"p"},"cubit.state"),"."),(0,r.kt)("p",null,"When the client sends a new message, we invoke the ",(0,r.kt)("inlineCode",{parentName:"p"},"increment"),"/",(0,r.kt)("inlineCode",{parentName:"p"},"decrement")," method on the cubit based on the message."),(0,r.kt)("p",null,"Finally, we unsubscribe the channel when the client disconnects."),(0,r.kt)("admonition",{type:"info"},(0,r.kt)("p",{parentName:"admonition"},"The ",(0,r.kt)("inlineCode",{parentName:"p"},"subscribe")," and ",(0,r.kt)("inlineCode",{parentName:"p"},"unsubscribe")," APIs are exposed by the ",(0,r.kt)("inlineCode",{parentName:"p"},"BroadcastCubit")," super class from ",(0,r.kt)("inlineCode",{parentName:"p"},"package:broadcast_bloc"),".")),(0,r.kt)("p",null,"Be sure to save all the changes and hot reload should kick in \u26a1\ufe0f"),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre"},"[hotreload] - Application reloaded.\n")),(0,r.kt)("p",null,"Now we can update our example script in ",(0,r.kt)("inlineCode",{parentName:"p"},"example/main.dart"),":"),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-dart"},"import 'package:web_socket_channel/web_socket_channel.dart';\n\nvoid main() async {\n  final channel = WebSocketChannel.connect(Uri.parse('ws://localhost:8080/ws'));\n  channel.stream.listen(print);\n\n  channel.sink.add('__increment__');\n  channel.sink.add('__decrement__');\n\n  channel.sink.close();\n}\n")),(0,r.kt)("p",null,"Finally, let's run the script:"),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre"},"dart example/main.dart\n")),(0,r.kt)("p",null,"We should see the following output:"),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre"},"0\n1\n0\n")),(0,r.kt)("admonition",{type:"note"},(0,r.kt)("p",{parentName:"admonition"},"If you restart the server, the count will always be reset to 0 because it is only maintained in memory.")),(0,r.kt)("p",null,"\ud83c\udf89 Congrats, you've created a real-time counter application using Dart Frog. View the ",(0,r.kt)("a",{parentName:"p",href:"https://github.com/VeryGoodOpenSource/dart_frog/tree/main/examples/web_socket_counter"},"full source code"),"."))}d.isMDXComponent=!0}}]);