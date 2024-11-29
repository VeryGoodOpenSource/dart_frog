"use strict";(self.webpackChunkdart_frog_docs=self.webpackChunkdart_frog_docs||[]).push([[43],{3659:(e,n,t)=>{t.r(n),t.d(n,{assets:()=>d,contentTitle:()=>s,default:()=>l,frontMatter:()=>o,metadata:()=>r,toc:()=>c});const r=JSON.parse('{"id":"advanced/authentication","title":"\ud83d\udd12 Authentication","description":"There are many different approaches, protocols, and services when tackling authentication in a backend, which can all be affected by the business logic of the application.","source":"@site/docs/advanced/authentication.md","sourceDirName":"advanced","slug":"/advanced/authentication","permalink":"/docs/advanced/authentication","draft":false,"unlisted":false,"editUrl":"https://github.com/VeryGoodOpenSource/dart_frog/tree/main/docs/docs/advanced/authentication.md","tags":[],"version":"current","sidebarPosition":7,"frontMatter":{"sidebar_position":7,"title":"\ud83d\udd12 Authentication"},"sidebar":"docs","previous":{"title":"\ud83d\udd11 Security Context","permalink":"/docs/advanced/security_context"},"next":{"title":"\u2694\ufe0f  Handling Cross-Origin Resource Sharing (CORS)","permalink":"/docs/advanced/cors"}}');var a=t(4848),i=t(8453);const o={sidebar_position:7,title:"\ud83d\udd12 Authentication"},s="Authentication \ud83d\udd11",d={},c=[{value:"Dart Frog Auth",id:"dart-frog-auth",level:2},{value:"Basic Authentication",id:"basic-authentication",level:2},{value:"Bearer Authentication",id:"bearer-authentication",level:2},{value:"Usage",id:"usage",level:2},{value:"Basic Method",id:"basic-method",level:3},{value:"Bearer Method",id:"bearer-method",level:3},{value:"Cookie-based Authentication",id:"cookie-based-authentication",level:3},{value:"Filtering Routes",id:"filtering-routes",level:3},{value:"Authentication vs. Authorization",id:"authentication-vs-authorization",level:3}];function h(e){const n={a:"a",code:"code",h1:"h1",h2:"h2",h3:"h3",header:"header",li:"li",p:"p",pre:"pre",ul:"ul",...(0,i.R)(),...e.components};return(0,a.jsxs)(a.Fragment,{children:[(0,a.jsx)(n.header,{children:(0,a.jsx)(n.h1,{id:"authentication-",children:"Authentication \ud83d\udd11"})}),"\n",(0,a.jsx)(n.p,{children:"There are many different approaches, protocols, and services when tackling authentication in a backend, which can all be affected by the business logic of the application."}),"\n",(0,a.jsx)(n.p,{children:"Because of this Dart Frog does not bundle any feature, helpers or resources for authentication out of the box. This means that developers have full freedom to implement server authentication in the best way that fits their needs."}),"\n",(0,a.jsxs)(n.p,{children:["Nevertheless, there are a few common patterns that can used in many different approaches to give the developer a head start. For example, there is a package called ",(0,a.jsx)(n.a,{href:"https://pub.dev/packages/dart_frog_auth",children:(0,a.jsx)(n.code,{children:"dart_frog_auth"})}),", which makes it easy for a simple authentication method to be implemented while also\nlayering the foundation for more advanced authentication. See below for more details:"]}),"\n",(0,a.jsx)(n.h2,{id:"dart-frog-auth",children:"Dart Frog Auth"}),"\n",(0,a.jsxs)(n.p,{children:["The authentication methods provided in ",(0,a.jsx)(n.code,{children:"dart_frog_auth"})," use different HTTP headers depending on the method. Basic and Bearer authentication use the ",(0,a.jsx)(n.code,{children:"Authorization"})," header, as defined in ",(0,a.jsx)(n.a,{href:"https://developer.mozilla.org/en-US/docs/Web/HTTP/Authentication",children:(0,a.jsx)(n.code,{children:"General HTTP"})}),", while Cookie-based authentication uses the ",(0,a.jsx)(n.code,{children:"Cookie"})," header, as defined in ",(0,a.jsx)(n.a,{href:"https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies",children:(0,a.jsx)(n.code,{children:"HTTP Cookies"})}),". The package provides support for Basic, Bearer, and Cookie-based authentications, which are common authentication methods used by many developers."]}),"\n",(0,a.jsx)(n.h2,{id:"basic-authentication",children:"Basic Authentication"}),"\n",(0,a.jsxs)(n.p,{children:["Like its name infers, this is a basic authentication scheme that consists of the client sending\na user's credentials in the ",(0,a.jsx)(n.code,{children:"Authorization"})," header. The credentials should be concatenated by a\ncolon and encoded in a base64 string. The encoded credentials are then set in the header as\nfollows:"]}),"\n",(0,a.jsx)(n.pre,{children:(0,a.jsx)(n.code,{children:"Authorization: Basic TOKEN\n"})}),"\n",(0,a.jsx)(n.p,{children:"Due to the credentials being sent encoded and not encrypted, this authentication can be considered\nless secure, especially when used without HTTPS/TLS."}),"\n",(0,a.jsx)(n.h2,{id:"bearer-authentication",children:"Bearer Authentication"}),"\n",(0,a.jsx)(n.p,{children:"Similar to the basic authentication scheme, the bearer authentication scheme sends a user's credentials to the header with a single token instead of a username and password."}),"\n",(0,a.jsx)(n.p,{children:"The bearer token format is up to the issuing authority server to define. It commonly\nconsists of an access token with encrypted information that the server can validate."}),"\n",(0,a.jsx)(n.p,{children:"The header is defined as follows:"}),"\n",(0,a.jsx)(n.pre,{children:(0,a.jsx)(n.code,{children:"Authorization: Bearer TOKEN\n"})}),"\n",(0,a.jsx)(n.h2,{id:"usage",children:"Usage"}),"\n",(0,a.jsx)(n.p,{children:"Both authentication schemes described above can be applied in a Dart Frog server by adding middleware to the routes that needs to be secured."}),"\n",(0,a.jsx)(n.p,{children:"Consider the following application:"}),"\n",(0,a.jsx)(n.pre,{children:(0,a.jsx)(n.code,{children:"lib/\n  |- user_repository.dart\nroutes/\n  |- admin/\n  |    |- index.dart\n  |- posts/\n       |- index.dart\n"})}),"\n",(0,a.jsxs)(n.p,{children:["Routes under ",(0,a.jsx)(n.code,{children:"posts"})," are public, so they don't require any kind of authentication, while on\n",(0,a.jsx)(n.code,{children:"admin"}),", only authenticated users can access their endpoints. It's worth noting that the\n",(0,a.jsx)(n.code,{children:"user_repository.dart"})," file under the ",(0,a.jsx)(n.code,{children:"lib"})," folder offers methods to authenticate users."]}),"\n",(0,a.jsx)(n.h3,{id:"basic-method",children:"Basic Method"}),"\n",(0,a.jsxs)(n.p,{children:["To implement the basic authentication scheme on ",(0,a.jsx)(n.code,{children:"admin"})," routes, a middleware file should\nbe created under the admin folder with the following content:"]}),"\n",(0,a.jsx)(n.pre,{children:(0,a.jsx)(n.code,{className:"language-dart",children:"// routes/admin/_middleware.dart\nimport 'package:dart_frog/dart_frog.dart';\nimport 'package:dart_frog_auth/dart_frog_auth.dart';\nimport 'package:blog/user.dart';\n\nHandler middleware(Handler handler) {\n  final userRepository = ...;\n  return handler\n      .use(requestLogger())\n      .use(\n        basicAuthentication<User>(\n          authenticator: (context, username, password) {\n            final userRepository = context.read<UserRepository>();\n            return userRepository.fetchFromCredentials(username, password);\n          },\n        ),\n      );\n}\n"})}),"\n",(0,a.jsxs)(n.p,{children:["The ",(0,a.jsx)(n.code,{children:"authenticator"})," parameter must be a method that receives three positional arguments (context, username\nand password) and returns a user if any is found for those credentials, otherwise it should return null."]}),"\n",(0,a.jsx)(n.p,{children:"If a user is returned (authenticated), it will be set in the request context and can be read by request handlers, for example:"}),"\n",(0,a.jsx)(n.pre,{children:(0,a.jsx)(n.code,{className:"language-dart",children:"import 'package:dart_frog/dart_frog.dart';\nimport 'package:blog/user.dart';\n\nResponse onRequest(RequestContext context) {\n  final user = context.read<User>();\n  return Response.json(body: {'user': user.id});\n}\n"})}),"\n",(0,a.jsxs)(n.p,{children:["In the case of ",(0,a.jsx)(n.code,{children:"null"})," being returned (unauthenticated), the middleware will automatically send an unauthorized ",(0,a.jsx)(n.code,{children:"401"})," in the response."]}),"\n",(0,a.jsx)(n.h3,{id:"bearer-method",children:"Bearer Method"}),"\n",(0,a.jsxs)(n.p,{children:["To implement the bearer authentication scheme on ",(0,a.jsx)(n.code,{children:"admin"})," routes, the same logic used for the\nbasic method can be applied:"]}),"\n",(0,a.jsx)(n.pre,{children:(0,a.jsx)(n.code,{className:"language-dart",children:"// routes/admin/_middleware.dart\nimport 'package:dart_frog/dart_frog.dart';\nimport 'package:dart_frog_auth/dart_frog_auth.dart';\nimport 'package:blog/user.dart';\n\nHandler middleware(Handler handler) {\n  final userRepository = ...;\n  return handler\n      .use(requestLogger())\n      .use(\n        bearerTokenAuthentication<User>(\n          authenticator: (context, token) {\n            final userRepository = context.read<UserRepository>();\n            return userRepository.fetchFromAccessToken(token);\n          }\n        ),\n      );\n}\n"})}),"\n",(0,a.jsxs)(n.p,{children:["The ",(0,a.jsx)(n.code,{children:"authenticator"})," parameter must be a function that receives two positional argument the\ncontext and the token sent on the authorization header and returns a user if any is found\nfor that token."]}),"\n",(0,a.jsx)(n.p,{children:"Again, just like in the basic method, if a user is returned, it will be set in the request\ncontext and can be read on request handlers, for example:"}),"\n",(0,a.jsx)(n.pre,{children:(0,a.jsx)(n.code,{className:"language-dart",children:"import 'package:dart_frog/dart_frog.dart';\nimport 'package:blog/user.dart';\n\nResponse onRequest(RequestContext context) {\n  final user = context.read<User>();\n  return Response.json(body: {'user': user.id});\n}\n"})}),"\n",(0,a.jsxs)(n.p,{children:["In the case of ",(0,a.jsx)(n.code,{children:"null"})," being returned (unauthenticated), the middleware will automatically send an unauthorized ",(0,a.jsx)(n.code,{children:"401"})," in the response."]}),"\n",(0,a.jsx)(n.h3,{id:"cookie-based-authentication",children:"Cookie-based Authentication"}),"\n",(0,a.jsxs)(n.p,{children:["To implement cookie-based authentication, you can use the ",(0,a.jsx)(n.code,{children:"cookieAuthentication"})," middleware:"]}),"\n",(0,a.jsx)(n.pre,{children:(0,a.jsx)(n.code,{className:"language-dart",children:"// routes/admin/_middleware.dart\nimport 'package:dart_frog/dart_frog.dart';\nimport 'package:dart_frog_auth/dart_frog_auth.dart';\nimport 'package:blog/user.dart';\n\nHandler middleware(Handler handler) {\n  final userRepository = ...;\n  return handler\n      .use(requestLogger())\n      .use(\n        cookieAuthentication<User>(\n          authenticator: (context, cookies) {\n            final userRepository = context.read<UserRepository>();\n            return userRepository.fetchFromAccessCookies(cookies);\n          }\n        ),\n      );\n}\n"})}),"\n",(0,a.jsxs)(n.p,{children:["The ",(0,a.jsx)(n.code,{children:"authenticator"})," parameter must be a function that receives two positional argument the\ncontext and the cookies set in the cookie header and returns a user if any is found\nfor that token."]}),"\n",(0,a.jsx)(n.p,{children:"Just like in the basic and bearer methods, if a user is returned, it will be set in the request\ncontext and can be read on request handlers, for example:"}),"\n",(0,a.jsx)(n.pre,{children:(0,a.jsx)(n.code,{className:"language-dart",children:"import 'package:dart_frog/dart_frog.dart';\nimport 'package:blog/user.dart';\n\nResponse onRequest(RequestContext context) {\n  final user = context.read<User>();\n  return Response.json(body: {'user': user.id});\n}\n"})}),"\n",(0,a.jsxs)(n.p,{children:["In the case of ",(0,a.jsx)(n.code,{children:"null"})," being returned (unauthenticated), the middleware will automatically send an unauthorized ",(0,a.jsx)(n.code,{children:"401"})," in the response."]}),"\n",(0,a.jsx)(n.h3,{id:"filtering-routes",children:"Filtering Routes"}),"\n",(0,a.jsx)(n.p,{children:"In many instances, developers will want to apply authentication to some routes, while not to others."}),"\n",(0,a.jsx)(n.p,{children:"One of those can be described by looking at implementing a basic RESTful CRUD API. In order to make\nsuch an API that allows consumers to create, update, delete, and get user information, the following list\nof routes will need to be created:"}),"\n",(0,a.jsxs)(n.ul,{children:["\n",(0,a.jsxs)(n.li,{children:[(0,a.jsx)(n.code,{children:"POST /users"}),": Creates a user"]}),"\n",(0,a.jsxs)(n.li,{children:[(0,a.jsx)(n.code,{children:"PATCH /users/[id]"}),": Updates the user with the given id."]}),"\n",(0,a.jsxs)(n.li,{children:[(0,a.jsx)(n.code,{children:"DELETE /users/[id]"}),": Deletes the user with the given id."]}),"\n",(0,a.jsxs)(n.li,{children:[(0,a.jsx)(n.code,{children:"GET /users/[id]"}),": Returns the user with the given id."]}),"\n"]}),"\n",(0,a.jsx)(n.p,{children:"Those endpoints can be translated to the following structure in a Dart Frog backend:"}),"\n",(0,a.jsx)(n.pre,{children:(0,a.jsx)(n.code,{children:"routes/\n  |- users/\n      |- index.dart // Handles the POST\n      |- [id].dart // Handles PATCH, DELETE and GET\n      |- _middleware.dart\n"})}),"\n",(0,a.jsxs)(n.p,{children:["It would make sense for the ",(0,a.jsx)(n.code,{children:"PATCH"}),", ",(0,a.jsx)(n.code,{children:"DELETE"}),", and ",(0,a.jsx)(n.code,{children:"GET"})," routes to be authenticated ones, since\nonly an authenticated user would be allowed to change this information."]}),"\n",(0,a.jsxs)(n.p,{children:["To accomplish that, we need the middleware to apply authentication to all routes except ",(0,a.jsx)(n.code,{children:"POST"}),"."]}),"\n",(0,a.jsxs)(n.p,{children:["Such behavior is possible with the use of the ",(0,a.jsx)(n.code,{children:"applies"})," optional predicate:"]}),"\n",(0,a.jsx)(n.pre,{children:(0,a.jsx)(n.code,{className:"language-dart",children:"Handler middleware(Handler handler) {\n  final userRepository = UserRepository();\n\n  return handler\n      .use(requestLogger())\n      .use(provider<UserRepository>((_) => userRepository))\n      .use(\n        basicAuthentication<User>(\n          authenticator: (context, username, password) {\n            final userRepository = context.read<UserRepository>();\n            return userRepository.userFromCredentials(username, password);\n          },\n          applies: (RequestContext context) async =>\n              context.request.method != HttpMethod.post,\n        ),\n      );\n}\n"})}),"\n",(0,a.jsxs)(n.p,{children:["In the above example, only routes that are not ",(0,a.jsx)(n.code,{children:"POST"})," will have authentication checked."]}),"\n",(0,a.jsx)(n.h3,{id:"authentication-vs-authorization",children:"Authentication vs. Authorization"}),"\n",(0,a.jsx)(n.p,{children:"Both Authentication and authorization are related, but are different concepts that are often confused."}),"\n",(0,a.jsx)(n.p,{children:"Authentication is about WHO the user is, while authorization is about WHAT a user can do."}),"\n",(0,a.jsx)(n.p,{children:"These concepts are related since we need to know who the user is in order to check if they can\nperform or not a given operation."}),"\n",(0,a.jsxs)(n.p,{children:[(0,a.jsx)(n.code,{children:"dart_frog_auth"})," only solves the authentication part of the problem. To enforce\nauthorization, it is up to the developer to implement it manually, or use an authorization issue\nsystem like OAuth2, for example."]}),"\n",(0,a.jsxs)(n.p,{children:["In technical terms, a request should return ",(0,a.jsx)(n.code,{children:"401"})," (Unauthorized) when authentication fails and\n",(0,a.jsx)(n.code,{children:"403"})," (Forbidden) when authorization failed."]}),"\n",(0,a.jsxs)(n.p,{children:["The following snippet shows how authorization can be manually checked in ",(0,a.jsx)(n.code,{children:"DELETE /users/[id]"})," route,\nwhere only the current logged user is allowed to delete itself:"]}),"\n",(0,a.jsx)(n.pre,{children:(0,a.jsx)(n.code,{className:"language-dart",children:"Future<Response> onRequest(RequestContext context, String id) async {\n  return switch (context.request.method) {\n    HttpMethod.delete => _deleteUser(context, id),\n    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),\n  };\n}\n\nFuture<Response> _deleteUser(RequestContext context, String id) async {\n  // If there is no authenticated user, `dart_frog_auth` automatically\n  // responds with a 401.\n\n  final user = context.read<User>();\n  if (user.id != id) {\n    // If the current authenticated user, obtained via `context.read<User>` is\n    // not the same of the one of the incoming request, a forbidden is returned!\n    return Response(statusCode: HttpStatus.forbidden);\n  }\n  await context.read<UserRepository>().deleteUser(user.id);\n  return Response(statusCode: HttpStatus.noContent);\n}\n"})})]})}function l(e={}){const{wrapper:n}={...(0,i.R)(),...e.components};return n?(0,a.jsx)(n,{...e,children:(0,a.jsx)(h,{...e})}):h(e)}},8453:(e,n,t)=>{t.d(n,{R:()=>o,x:()=>s});var r=t(6540);const a={},i=r.createContext(a);function o(e){const n=r.useContext(i);return r.useMemo((function(){return"function"==typeof e?e(n):{...n,...e}}),[n,e])}function s(e){let n;return n=e.disableParentContext?"function"==typeof e.components?e.components(a):e.components||a:o(e.components),r.createElement(i.Provider,{value:n},e.children)}}}]);