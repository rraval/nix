# Utility functions with no dependencies on anything but `builtins`
rec {
  /* Filter a list by a predicate expecting to only get one match

     Type: findOne :: (a -> Boolean) -> [a] -> a
   */
  findOne = pred: lst: let
    filtered = builtins.filter pred lst;
    len = builtins.length filtered;
  in
    assert len == 1; builtins.head filtered
  ;

  /* Extract the name without version number from a derivation.

     Type: getDerivationName :: Derivation -> String
  */
  getDerivationName = drv: (builtins.parseDrvName drv.name).name;

  /* Find a package by name.

     Type: findPackage :: [Derivation] -> String -> Derivation
  */
  findPackage = drvs: name: findOne (d: getDerivationName d == name) drvs;
}
