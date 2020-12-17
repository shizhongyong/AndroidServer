<!doctype html>

<%@ page contentType="text/html; charset=UTF-8" language="java"%>
<%@ page import="java.util.*"%>
<%@ page import="java.text.*"%>
<%@ page import="java.net.*"%>
<%@ page import="java.io.*"%>
<%@ page import="java.lang.reflect.Type"%>
<%@ page import="com.google.gson.*"%>
<%@ page import="com.google.gson.reflect.TypeToken"%>
<%@ page import="java.net.InetAddress"%>

<%!
  public static List<String> loadApps(HttpServletRequest request) {
    List<String> apps = new ArrayList<>();
    try {
      File root = new File(request.getServletContext().getRealPath(""));
      File build = new File(root, "build");
      File[] appDirs = build.listFiles();
      if (appDirs != null && appDirs.length > 0) {
        Arrays.sort(appDirs, new Comparator<File>() {
          @Override
          public int compare(File f1, File f2) {
              return f1.compareTo(f2);
          }
        });
        
        for (File dir : appDirs) {
          if (!dir.isDirectory()) {
            continue;
          }
          if (!dir.getName().matches("^(.+\\.)+[^.]+$")) {
            continue;
          }

          String json = loadFile(new File(dir, "app.json"));
          if (json != null) {
            apps.add(json);
          }
        }
      }
    } catch (Exception e) {
      e.printStackTrace();
    }

    return apps;
  }

  public static String loadFile(File file) {
    try {
      BufferedReader reader = new BufferedReader(new FileReader(file));
      StringBuilder builder = new StringBuilder();
      String line = null;
      while ((line = reader.readLine()) != null) {
        builder.append(line);
      }
      reader.close();
      reader = null;

      return builder.toString();
    } catch (Exception e) {
      e.printStackTrace();
    }

    return null;
  }

  public static String getPropertyFromMap(Map<String, String> map, String key) {
    if (map == null || key == null) {
      return "";
    }

    String value = map.get(key);
    if (value == null) {
      return "";
    }

    return value;
  }
%>

<%
  String localIp = InetAddress.getLocalHost().getHostAddress();
  String serverUrl = "http://" + localIp;
  List<String> appList = loadApps(request);
%>

<html lang="zh-CN">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <meta name="description" content="">
    <meta name="author" content="">
    <link rel="icon" href="image/favicon.ico">

    <title>客户端首页</title>

    <!-- Bootstrap core CSS -->
    <link href="https://cdn.bootcss.com/bootstrap/4.0.0/css/bootstrap.min.css" rel="stylesheet">

    <!-- Custom styles for this template -->
    <link href="css/album.css" rel="stylesheet">
  </head>

  <body>

    <script src="https://static.runoob.com/assets/qrcode/qrcode.min.js"></script>

    <header>
      <div class="navbar navbar-dark bg-dark box-shadow">
        <div class="container d-flex justify-content-between">
          <a href="#" class="navbar-brand d-flex align-items-center">
            <img src="image/logo.png" width="120" height="36" alt="logo">
            <strong>&nbsp;&nbsp;客户端</strong>
          </a>
          <nav class="navbar navbar-expand-lg navbar-light">
            <div class="collapse navbar-collapse" id="navbarNav">
              <ul class="navbar-nav">
                <li class="nav-item active">
                  <a class="nav-link" href="#">Home <span class="sr-only">(current)</span></a>
                </li>
                <li class="nav-item">
                  <a class="nav-link" href="/jenkins">Jenkins</a>
                </li>
                <li class="nav-item">
                  <a class="nav-link" href="/release">Release</a>
                </li>
                <li class="nav-item">
                  <a class="nav-link" href="/iOS">iOS</a>
                </li>
                <li class="nav-item">
                  <a class="nav-link" href="/barcode.html" target="_blank">条形码</a>
                </li>
                <li class="nav-item">
                  <a class="nav-link" href="#">About</a>
                </li>
              </ul>
            </div>
          </nav>
        </div>
      </div>
    </header>

    <main role="main">

      <!--
      <section class="jumbotron text-center">
        <div class="container">
          <h1 class="jumbotron-heading">Album example</h1>
          <p class="lead text-muted">Something short and leading about the collection below—its contents, the creator, etc. Make it short and sweet, but not too short so folks don't simply skip over it entirely.</p>
          <p>
            <a href="#" class="btn btn-primary my-2">Main call to action</a>
            <a href="#" class="btn btn-secondary my-2">Secondary action</a>
          </p>
        </div>
      </section>
      -->

      <div class="album py-5 bg-light">
        <div class="container">

          <div class="row">

            <%
              String name;
              String versionName;
              String packageName;
              String buildTime;
              String[] features;
              String apkPath;
              String mappingPath;

              Gson gson = new Gson();
              Type type = new TypeToken<Map<String, String>>() {}.getType();
              for (String json : appList) {
                try {
                  Map<String, String> map = gson.fromJson(json, type);
                  name = getPropertyFromMap(map, "name");
                  versionName = getPropertyFromMap(map, "versionName");
                  packageName = getPropertyFromMap(map, "packageName");
                  buildTime = getPropertyFromMap(map, "buildTime");
                  features = getPropertyFromMap(map, "features").split("\n");
                  apkPath = "build/" + packageName + "/app.apk";
                  mappingPath = "build/" + packageName;
                  
                  out.println("<div class=\"col-md-4\">");
                  out.println("<div class=\"card mb-4 box-shadow\">");
                  out.println("<div class=\"card-body\">");

                  out.println("<div class=\"d-flex\">");
                  out.println("<img src=\"build/" + packageName + "/icon.png\" width=\"60\" height=\"60\" alt=\"logo\">");
                  out.println("<div style=\"padding-left: 1.25rem\">");
                  out.println("<h4>" + name + "</h4>");
                  out.println("<p>" + buildTime + "</p>");
                  out.println("</div>");
                  out.println("</div>");


                  String linkId = "link-" + packageName;
                  String qrcodeId = "qr-" + packageName;

                  out.println("<a href=\"" + apkPath + "\" id=\"" + linkId + "\">");
                  out.println("<div id=\"" + qrcodeId + "\" style=\"width: 200px; height: 200px; margin-left: auto; margin-right: auto;\">");
                  out.println("</div>");
                  out.println("</a>");

                  out.println("<script type=\"text/javascript\">");
                  out.println("var qrcode = new QRCode(document.getElementById(\"" + qrcodeId + "\"), {width : 200, height : 200});");
                  out.println("qrcode.makeCode(document.getElementById(\"" + linkId +"\").href);");
                  out.println("</script>");


                  out.println("<div style=\"padding-top: 1.25rem; padding-bottom: 1.25rem\">");
                  out.println("<H6>当前版本：" + versionName + "</H6>");
                  out.println("<H6>更新内容：</H6>");
                  for (String feature : features) {
                    out.println("<p class=\"card-text\" style=\"margin: 0\">" + feature + "</p>");
                  }
                  out.println("</div>");

                  out.println("<div class=\"d-flex justify-content-between align-items-center\">");
                  out.println("<div class=\"btn-group\">");

                  out.println("<a href=\"" + mappingPath + "\">");
                  out.println("<button type=\"button\" class=\"btn btn-sm btn-outline-secondary\">Mapping</button>");
                  out.println("</a>");

                  out.println("<a href=\"" + apkPath + "\">");
                  out.println("<button type=\"button\" class=\"btn btn-sm btn-outline-secondary\">Download</button>");
                  out.println("</a>");

                  out.println("</div>");
                  out.println("</div>");

                  out.println("</div>");
                  out.println("</div>");
                  out.println("</div>");

                } catch (Exception e) {
                  e.printStackTrace();
                }

              }
            %>
            
            <!--
            <div class="col-md-4">
              <div class="card mb-4 box-shadow">
                <div class="card-body">
                  <div class="d-flex">
                    <img src="build/com.wulianshuntong.driver/icon.png" width="60" height="60" alt="logo">
                    <div style="padding-left: 1.25rem">
                      <h4>顺立通司机端</h4>
                      <p>2019-01-10 18:40:56</p>
                    </div>
                  </div>

                  <a href="http://www.baidu.com" id="testlink">
                    <div id="qrcode" style="width: 200px; height: 200px; margin-left: auto; margin-right: auto;"></div>
                  </a>
                  
                  <script type="text/javascript">
                    var qrcode = new QRCode(document.getElementById("qrcode"), {
                      width : 200,
                      height : 200
                    });
                
                    qrcode.makeCode(document.getElementById("testlink").href);
                  </script>

                  <div style="padding-top: 1.25rem; padding-bottom: 1.25rem">
                    <H6>当前版本：1.2.0</H6>
                    <H6>更新内容：</H6>
                    <p class="card-text" style="margin: 0">1、修改了一些东西</p>
                    <p class="card-text" style="margin: 0">2、修改了一些东西</p>
                  </div>
                  
                  <div class="d-flex justify-content-between align-items-center">
                    <div class="btn-group">
                      <button type="button" class="btn btn-sm btn-outline-secondary">Mapping</button>
                      <button type="button" class="btn btn-sm btn-outline-secondary">Download</button>
                    </div>
                  </div>
                </div>
              </div>
            </div>
            -->

          </div>
        </div>
      </div>

    </main>

    <footer class="text-muted">
      <div class="container">
        <p class="float-right">
          <a href="#">Back to top</a>
        </p>
        <p>&copy; Client Team 2019</p>
      </div>
    </footer>

    <!-- Bootstrap core JavaScript
    ================================================== -->
    <!-- Placed at the end of the document so the pages load faster -->
    <script src="https://code.jquery.com/jquery-3.2.1.slim.min.js" integrity="sha384-KJ3o2DKtIkvYIK3UENzmM7KCkRr/rE9/Qpg6aAZGJwFDMVNA/GpGFF93hXpG5KkN" crossorigin="anonymous"></script>
    <script>window.jQuery || document.write('<script src="../../../../assets/js/vendor/jquery-slim.min.js"><\/script>')</script>
    <script src="../../../../assets/js/vendor/popper.min.js"></script>
    <script src="../../../../dist/js/bootstrap.min.js"></script>
    <script src="../../../../assets/js/vendor/holder.min.js"></script>
  </body>
</html>
