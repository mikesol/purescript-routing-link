module Test.Main where

import Prelude hiding ((/))

import Data.Foldable (oneOf)
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Data.Show.Generic (genericShow)
import Deku.Attributes (id_)
import Deku.Control (switcher_, text_)
import Deku.Core (Nut)
import Deku.DOM as D
import Deku.Listeners (click)
import Deku.Toplevel (runInBody)
import Effect (Effect)
import FRP.Event (Event, create)
import Routing.Duplex (RouteDuplex(..), RouteDuplex', path, root)
import Routing.Duplex.Generic as G
import Routing.Duplex.Generic.Syntax ((/))
import Routing.Duplex.Parser (RouteParser(..), RouteResult(..))
import Routing.Hash.Link (matchesWith)

data Route
  = Home
  | Foo (Maybe Int)
  | Bar (Maybe Boolean)
  | Baz

derive instance genericRoute :: Generic Route _
derive instance eqRoute :: Eq Route

instance showRoute :: Show Route where
  show = genericShow

cached :: forall a. RouteDuplex' (Maybe a)
cached = RouteDuplex (const mempty) $ Chomp (flip Success Nothing)

route :: RouteDuplex' Route
route = root $ G.sum
  { "Home": G.noArgs
  , "Foo": "foo" / cached
  , "Bar": cached / "bar"
  , "Baz": path "baz" G.noArgs
  }

app :: (Route -> Effect Unit) -> Event Route -> Nut
app navigateTo routeEvent = routeEvent # switcher_ D.div case _ of
  Home -> D.button
    ( oneOf
        [ id_ "clickhome"
        , click $ pure (navigateTo (Foo (Just 1)))
        ]
    )
    [ text_ "to foo" ]
  Foo foo -> D.div_
    [ D.span (id_ "resfoo") [ text_ (show foo) ]
    , D.button
        ( oneOf
            [ id_ "clickfoo"
            , click $ pure (navigateTo (Bar (Just true)))
            ]
        )
        [ text_ "to bar" ]
    ]
  Bar bar -> D.div_
    [ D.span (id_ "resbar") [ text_ (show bar) ]
    , D.div_
        [ D.button
            ( oneOf
                [ id_ "clickbar"
                , click $ pure (navigateTo Baz)
                ]
            )
            [ text_ "to baz" ]
        ]
    ]
  Baz -> D.button
    ( oneOf
        [ id_ "clickbaz"
        , click $ pure (navigateTo Home)
        ]
    )
    [ text_ "to home" ]

main :: Effect Unit
main = do
  io <- create
  { navigateTo } <- matchesWith route (const io.push)
  runInBody (app navigateTo (oneOf [pure Home, io.event]))