package modelo;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class Carrito implements Serializable {

    private int idFuncion;
    private List<String> butacas = new ArrayList<>(); 
    private Map<Integer, Integer> productos = new LinkedHashMap<>();

    public Carrito() {
    }

    public int getIdFuncion() {
        return idFuncion;
    }

    public void setIdFuncion(int idFuncion) {
        this.idFuncion = idFuncion;
    }

    public List<String> getButacas() {
        return butacas;
    }

    public void setButacas(List<String> butacas) {
        this.butacas = butacas;
    }

    public Map<Integer, Integer> getProductos() {
        return productos;
    }

    public void setProductos(Map<Integer, Integer> productos) {
        this.productos = productos;
    }

    public int getCantidadEntradas() {
        return butacas.size();
    }

    public boolean isVacio() {
        return butacas.isEmpty() && productos.isEmpty();
    }

    public void vaciar() {
        idFuncion = 0;
        butacas.clear();
        productos.clear();
    }
}
