
package filtro;

import java.io.IOException;
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletResponse;

@WebFilter("/*")
public class CabecerasFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig)
            throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest request,
                         ServletResponse response,
                         FilterChain chain)
            throws IOException, ServletException {

        HttpServletResponse respuesta =
                (HttpServletResponse) response;

        respuesta.setHeader("X-Frame-Options", "DENY");
        respuesta.setHeader("X-Content-Type-Options", "nosniff");
        respuesta.setHeader("Referrer-Policy", "no-referrer");
        respuesta.setHeader("Content-Security-Policy",
                "default-src 'self'");

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
    }
}
