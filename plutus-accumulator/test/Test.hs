import Lib (helloWorld)

main :: IO ()
main = putStrLn $ helloWorld ++ " from test"