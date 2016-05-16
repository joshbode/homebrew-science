class RGui < Formula
  desc "R.app Cocoa GUI for the R Programming Language"
  homepage "http://cran.r-project.org/bin/macosx/"
  url "http://cran.r-project.org/bin/macosx/Mac-GUI-1.68.tar.gz"
  sha256 "7dff17659a69e3c492fdfc3fb765e3c9537157d50b6886236bee7ad873eb416d"

  head "https://svn.r-project.org/R-packages/trunk/Mac-GUI"

  bottle do
    cellar :any
    sha256 "7da296d529c70c94f88902f0a216c75057095a3d5e0094d6d6fe82a47089de0c" => :el_capitan
    sha256 "b357a5396f7f2eabf7b1d48135666f18b164c49c7cad9bda1066d2a91cbbe9c0" => :yosemite
    sha256 "a1daa51392bf3ab2704fbf6335685d09269514773e0eb5ceda8ae4873513092e" => :mavericks
  end

  depends_on :xcode
  depends_on :macos => :snow_leopard
  depends_on :arch => :x86_64

  depends_on "r"

  # patch to allow zero as return value for R_ReplDLLdo1() in main REPL loop
  patch :DATA

  def install
    # ugly hack to get updateSVN script in build to not fail
    cp_r cached_download/".svn", buildpath if build.head?

    # relax HTTP security to allow HTTP connection to local help server
    plb "Info.plist",
        "Add :NSAppTransportSecurity:NSAllowsArbitraryLoads bool",
        "Set :NSAppTransportSecurity:NSAllowsArbitraryLoads true"

    r_prefix = Formula["r"].opt_prefix
    build = "Release"

    xcodebuild "-target", "R", "-configuration", build, "SYMROOT=build",
               "HEADER_SEARCH_PATHS=#{r_prefix}/R.framework/Headers",
               "OTHER_LDFLAGS=-F#{r_prefix}"

    prefix.install "build/#{build}/R.app"
  end

  # apply PlistBuddy commands
  def plb(filename, *actions)
    actions.each do |action|
      system "/usr/libexec/PlistBuddy", "-c", action, filename
    end
  end
end

__END__
diff --git a/REngine/Rinit.m b/REngine/Rinit.m
index b6e171b..a1b99af 100644
--- a/REngine/Rinit.m
+++ b/REngine/Rinit.m
@@ -161,7 +161,7 @@ void run_REngineRmainloop(int delayed)
     }
 
     main_loop_result = 1;
-    while (main_loop_result > 0) {
+    while (main_loop_result >= 0) {
 	@try {
 #ifdef USE_POOLS
 	    if (main_loop_pool) {
