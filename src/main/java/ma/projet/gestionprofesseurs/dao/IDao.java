package ma.projet.gestionprofesseurs.dao;

import java.util.List;

public interface IDao <T>{
    /*@
      @ requires o != null;
      @ ensures \result != null;
      @*/
    T create (T o);
    
    /*@
      @ requires o != null;
      @ ensures \result == true || \result == false;
      @*/
    boolean  delete(T o);
    
    /*@
      @ requires o != null;
      @ ensures \result != null;
      @*/
    T update(T o);
    
    /*@
      @ ensures \result != null;
      @*/
    List<T> findAll();
    
    /*@
      @ requires id >= 0;
      @*/
    T findById (int id);
}
