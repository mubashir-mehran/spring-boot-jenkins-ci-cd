package ma.projet.gestionprofesseurs.entities;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;

/*@
  @ public invariant id >= 0;
  @ public invariant code != null;
  @ public invariant libelle != null;
  @*/
@Entity
public class Specialite {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    private String code;
    private String libelle;

    /*@
      @ ensures this.code == null && this.libelle == null && this.id == 0;
      @*/
    public Specialite() {
    }

    /*@
      @ requires code != null;
      @ requires libelle != null;
      @ ensures this.code == code;
      @ ensures this.libelle == libelle;
      @*/
    public Specialite(String code, String libelle) {
        this.code = code;
        this.libelle = libelle;
    }

    /*@
      @ ensures \result == id;
      @*/
    public int getId() {
        return id;
    }

    /*@
      @ requires id >= 0;
      @ ensures this.id == id;
      @*/
    public void setId(int id) {
        this.id = id;
    }

    /*@
      @ ensures \result == code;
      @*/
    public String getCode() {
        return code;
    }

    /*@
      @ requires code != null;
      @ ensures this.code == code;
      @*/
    public void setCode(String code) {
        this.code = code;
    }

    /*@
      @ ensures \result == libelle;
      @*/
    public String getLibelle() {
        return libelle;
    }

    /*@
      @ requires libelle != null;
      @ ensures this.libelle == libelle;
      @*/
    public void setLibelle(String libelle) {
        this.libelle = libelle;
    }
}
