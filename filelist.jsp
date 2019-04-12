<!doctype html>

<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ page import="java.util.*"%>
<%@ page import="java.text.*"%>
<%@ page import="java.net.*"%>
<%@ page import="java.io.*"%>

<%!
	private List<File> listFiles(File dir) {
        File[] files = dir.listFiles();
        if (files == null || files.length == 0) {
            return null;
        }

        List<File> list = new ArrayList<>();
        List<String> excludeFiles = Arrays.asList("index.jsp", "index.html", "index.htm");
        for (File file : files) {
            if (!excludeFiles.contains(file.getName().toLowerCase())) {
                list.add(file);
            }
        }

        Collections.sort(list, new Comparator<File>() {
            @Override
            public int compare(File f1, File f2) {
                return Long.compare(f2.lastModified(), f1.lastModified());
            }
        });

        return list;
    }

	private String getFileSize(File file) {
		String[] units = {"B", "KB", "MB", "GB", "TB"};
		double size = 0;
		int unit = 0;
		if (file != null && file.isFile()) {
			size = file.length();
			while(size >= 1024) {
				size /= 1024;
				unit++;
			}
		}
		if (unit <= 1) {
			return (int)size + units[unit];
		}
		return String.format(Locale.CHINA, "%.1f", size) + units[unit];
	}
%>

<%
  String path = request.getServletPath();
  path = path.substring(0, path.lastIndexOf("/") + 1);
  List<File> files = listFiles(new File(application.getRealPath(path)));
  SimpleDateFormat format = new SimpleDateFormat("yyyy年MM月dd日 E HH:mm:ss");
%>

<html>
<head>
<title>Directory Listing For [<%=path %>]</title>
<STYLE><!--h1 {font-family:Tahoma,Arial,sans-serif;color:white;background-color:#525D76;font-size:22px;} h2 {font-family:Tahoma,Arial,sans-serif;color:white;background-color:#525D76;font-size:16px;} h3 {font-family:Tahoma,Arial,sans-serif;color:white;background-color:#525D76;font-size:14px;} body {font-family:Tahoma,Arial,sans-serif;color:black;background-color:white;} b {font-family:Tahoma,Arial,sans-serif;color:white;background-color:#525D76;} p {font-family:Tahoma,Arial,sans-serif;background:white;color:black;font-size:12px;} a {color:black;} a.name {color:black;} .line {height:1px;background-color:#525D76;border:none;}--></STYLE> </head>
<body>
	<h1>Directory Listing For [<%=path %>] - <a href="/"><b>Up To [/]</b></a></h1>
	<HR size="1" noshade="noshade">
	<table width="100%" cellspacing="0" cellpadding="5" align="center">
		<tr>
			<td align="left"><font size="+1"><strong>文件名</strong></font></td>
			<td align="center"><font size="+1"><strong>大小</strong></font></td>
			<td align="right"><font size="+1"><strong>Last Modified</strong></font></td>
		</tr>
		<%
			if (files != null) {
				for (File file : files) {
					out.println("<tr>");
					out.println("<td align=\"left\">&nbsp;&nbsp;");
					out.println("<a href=\"" + file.getName() + "\"><tt>" + file.getName() + "</tt></a>");
					out.println("</td>");
					out.println("<td align=\"right\">");
					if (file.isFile()) {
						out.println("<tt>" + getFileSize(file) + "</tt>");
					}
					out.println("</td>");
					out.println("<td align=\"right\">");
					out.println("<tt>" + format.format(new Date(file.lastModified())) + "</tt>");
					out.println("</td>");
					out.println("</tr>");
				}
			}
		%>
	</table>
	<HR size="1" noshade="noshade"><h3>Apache Tomcat/9.0.14</h3>
</body>
</html>
