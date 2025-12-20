package ma.projet.gestionprofesseurs.entities;

import jakarta.persistence.*;

import java.util.Date;

/*@
  @ public invariant id >= 0;
  @ public invariant nom != null;
  @ public invariant prenom != null;
  @ public invariant telephone != null;
  @ public invariant email != null;
  @ public invariant dateEmbauche != null;
  @*/
@Entity
public class Professeur {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    private String nom;
    private String prenom;
    private String telephone;
    private String email;
    @Temporal(TemporalType.DATE)
    private Date dateEmbauche;

    @ManyToOne
    private Specialite specialite;

    /*@
      @ ensures this.nom == null && this.prenom == null && 
      @         this.telephone == null && this.email == null && 
      @         this.dateEmbauche == null && this.specialite == null && 
      @         this.id == 0;
      @*/
    public Professeur() {
    }

    /*@
      @ requires nom != null;
      @ requires prenom != null;
      @ requires telephone != null;
      @ requires email != null;
      @ requires dateEmbauche != null;
      @ requires specialite != null;
      @ ensures this.nom == nom;
      @ ensures this.prenom == prenom;
      @ ensures this.telephone == telephone;
      @ ensures this.email == email;
      @ ensures this.dateEmbauche == dateEmbauche;
      @ ensures this.specialite == specialite;
      @*/
    public Professeur(String nom, String prenom, String telephone, String email, Date dateEmbauche, Specialite specialite) {
        this.nom = nom;
        this.prenom = prenom;
        this.telephone = telephone;
        this.email = email;
        this.dateEmbauche = dateEmbauche;
        this.specialite = specialite;
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
      @ ensures \result == nom;
      @*/
    public String getNom() {
        return nom;
    }

    /*@
      @ requires nom != null;
      @ ensures this.nom == nom;
      @*/
    public void setNom(String nom) {
        this.nom = nom;
    }

    /*@
      @ ensures \result == prenom;
      @*/
    public String getPrenom() {
        return prenom;
    }

    /*@
      @ requires prenom != null;
      @ ensures this.prenom == prenom;
      @*/
    public void setPrenom(String prenom) {
        this.prenom = prenom;
    }

    /*@
      @ ensures \result == telephone;
      @*/
    public String getTelephone() {
        return telephone;
    }

    /*@
      @ requires telephone != null;
      @ ensures this.telephone == telephone;
      @*/
    public void setTelephone(String telephone) {
        this.telephone = telephone;
    }

    /*@
      @ ensures \result == email;
      @*/
    public String getEmail() {
        return email;
    }

    /*@
      @ requires email != null;
      @ ensures this.email == email;
      @*/
    public void setEmail(String email) {
        this.email = email;
    }

    /*@
      @ ensures \result == dateEmbauche;
      @*/
    public Date getDateEmbauche() {
        return dateEmbauche;
    }

    /*@
      @ requires dateEmbauche != null;
      @ ensures this.dateEmbauche == dateEmbauche;
      @*/
    public void setDateEmbauche(Date dateEmbauche) {
        this.dateEmbauche = dateEmbauche;
    }

    /*@
      @ ensures \result == specialite;
      @*/
    public Specialite getSpecialite() {
        return specialite;
    }

    /*@
      @ requires specialite != null;
      @ ensures this.specialite == specialite;
      @*/
    public void setSpecialite(Specialite specialite) {
        this.specialite = specialite;
    }
}
