# purescript-routing-link

A next.js-like link navigation library based on `purescript-routing`.

## Why?

Let's say that you have downloaded a user profile (username, avatar, bio, etc) and stored it in your application state.

If you use hashed-based routing to navigate to a profile page, you'd ideally like to hydrate the page with the cached profile instead of (or in addition to) re-downloading it from the server.

This library fixes this problem with the `matchesWith` function.

```purescript
matchesWith :: forall a. RouteDuplex' a -> (Maybe a -> a -> Effect Unit) -> Effect { unsubscribe :: Effect Unit, navigateTo :: a -> Effect Unit }
```

The signature is similar to `matchesWith` from `routing-hash`. The important bit is that it comes with a `navigateTo` function. Instead of using in-app navigation to a hash, ie `<a href="/#/foo">`, you'd do `navigateTo Foo`. The app will navigate to the correct hash (ie `/#/foo`) _and_ pass the data sent to `navigateTo` to the callback used in `matchesWith`.

See [`test/Main.purs`](test/Main.purs) and the corresponding [unit test](index.test.js) for an example.