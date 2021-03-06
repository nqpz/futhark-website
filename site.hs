--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts #-}
import           Data.Monoid ((<>))
import           Data.List (isPrefixOf)
import           System.FilePath
import           Hakyll
import           Text.Pandoc
import           Text.Pandoc.Walk

postCtx :: Context String
postCtx = mconcat
  [ modificationTimeField "mtime" "%U"
  , dateField "date" "%B %e, %Y"
  , defaultContext
  ]

--------------------------------------------------------------------------------
main :: IO ()
main = hakyllWith config $ do
    match "images/*" $ do
        route idRoute
        compile copyFileCompiler

    match "static/*" $ do
        route idRoute
        compile copyFileCompiler

    match "publications/*" $ do
        route idRoute
        compile copyFileCompiler

    match "benchmarks/programs/*" $ do
        route idRoute
        compile copyFileCompiler

    match "css/*" $ do
        route idRoute
        compile compressCssCompiler

    match (fromList ["performance.rst",
                     "docs.rst",
                     "getinvolved.rst",
                     "index.rst",
                     "examples.rst"]) $ do
        route $ setExtension "html"
        compile $ do
          menu <- contentContext
          pandocRstCompiler
            >>= loadAndApplyTemplate "templates/default.html" menu
            >>= relativizeUrls

    match "blog/*" $ do
        route $ setExtension "html"
        compile $ do
          postCtx <- postContext
          pandocRstCompiler
            >>= loadAndApplyTemplate "templates/post.html"    postCtx
            >>= loadAndApplyTemplate "templates/default.html" postCtx
            >>= relativizeUrls

    -- Post list
    create ["blog.html"] $ do
        route idRoute
        compile $ do
            menu <- getMenu
            posts <- recentFirst =<< loadAll "blog/*"
            let ctx = constField "title" "Developer Blog" <>
                      listField "posts" postCtx (return posts) <>
                      constField "menu" menu <>
                      defaultContext
            makeItem ""
                >>= loadAndApplyTemplate "templates/posts.html" ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= relativizeUrls

    match "templates/*" $ compile templateCompiler

contentContext :: Compiler (Context String)
contentContext = do
  menu <- getMenu
  return $
    defaultContext `mappend`
    constField "menu" menu

getMenu :: Compiler String
getMenu = do
  myRoute <- getRoute =<< getUnderlying
  return $ case myRoute of
             Nothing -> showMenu "" menuContents
             Just me -> showMenu me menuContents

menuContents :: [(String, FilePath)]
menuContents = [("Overview", "index.html"),
                ("Examples", "examples.html"),
                ("Docs", "docs.html"),
                ("Gotta Go Fast!", "performance.html"),
                ("Get Involved", "getinvolved.html"),
                ("Blog", "blog.html")]

showMenu :: FilePath -> [(String, FilePath)] -> String
showMenu this items = "<ul id=\"menu\">"++concatMap li items++"</ul>"
  where li (name, item)
          | isThis item = "<li id=\"chosen\"><a href=\"/"++item++"\">"++name++"</a></li>"
          | otherwise   = "<li><a href=\"/"++item++"\">"++name++"</a></li>"
        isThis item = dropExtension item `isPrefixOf` dropExtension this

--------------------------------------------------------------------------------
postContext :: Compiler (Context String)
postContext = do
  ctx <- contentContext
  return $ dateField "date" "%B %e, %Y" `mappend` ctx

--------------------------------------------------------------------------------

-- By default, RST will make all top-level titles <h1>s, but we prefer
-- to only have a single <h1>: the one in the template.  We use a
-- technique from
-- http://maxdelgiudice.com/posts/2015-07-08-rst-headers.html to avoid
-- this.

shiftHeaderUp :: Block -> Block
shiftHeaderUp h@(Header n a b)
    | n < 6     = Header (n+1) a b
    | otherwise = h
shiftHeaderUp x = x

shiftAll :: Pandoc -> Pandoc
shiftAll = walk shiftHeaderUp

pandocRstCompiler :: Compiler (Item String)
pandocRstCompiler = pandocCompilerWithTransform
   defaultHakyllReaderOptions
   defaultHakyllWriterOptions
   shiftAll

--------------------------------------------------------------------------------
config :: Configuration
config = defaultConfiguration
  { deployCommand = "rsync --chmod=Do+rx,Fo+r --checksum -ave 'ssh -p 22' \
                     \_site/* --exclude pub futhark@sigkill.dk:/var/www/htdocs/futhark-lang.org"
  }
