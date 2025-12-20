package ma.projet.gestionprofesseurs.controllers;


import ma.projet.gestionprofesseurs.entities.Professeur;
import ma.projet.gestionprofesseurs.entities.Specialite;
import ma.projet.gestionprofesseurs.repository.SpecialiteRepository;
import ma.projet.gestionprofesseurs.services.ProfesseurService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Date;
import java.util.List;

@RestController
@RequestMapping("/api/professeur")
public class ProfesseurController {
    @Autowired
    private ProfesseurService professeurService;
    @Autowired
    private SpecialiteRepository specialiteRepository;

    /*@
      @ ensures \result != null;
      @*/
    @GetMapping
    public List<Professeur> findAllProfesseur() {
        return professeurService.findAll();
    }

    /*@
      @ requires id >= 0;
      @ ensures \result != null;
      @ ensures (\result.getStatusCode() == HttpStatus.OK && 
      @             \result.getBody() instanceof Professeur) ||
      @         (\result.getStatusCode() == HttpStatus.BAD_REQUEST);
      @*/
    @GetMapping("/{id}")
    public ResponseEntity<Object> findById(@PathVariable int id) {
        Professeur professeur = professeurService.findById(id);
        if (professeur == null) {
            return new ResponseEntity<Object>("Professeur with ID " + id + " not found", HttpStatus.BAD_REQUEST);
        } else {
            return ResponseEntity.ok(professeur);
        }
    }

    /*@
      @ requires professeur != null;
      @ ensures \result != null;
      @ ensures \result.getId() > 0;
      @*/
    @PostMapping
    public Professeur createProfesseur(@RequestBody Professeur professeur) {
        professeur.setId(0);
        return professeurService.create(professeur);
    }

    /*@
      @ requires id >= 0;
      @ requires professeur != null;
      @ ensures \result != null;
      @ ensures (\result.getStatusCode() == HttpStatus.OK && 
      @             \result.getBody() instanceof Professeur) ||
      @         (\result.getStatusCode() == HttpStatus.BAD_REQUEST);
      @*/
    @PutMapping("/{id}")
    public ResponseEntity<Object> updateProfesseur(@PathVariable int id, @RequestBody Professeur professeur) {

        if (professeurService.findById(id) == null) {
            return new ResponseEntity<Object>("Professeur with ID " + id + " not found", HttpStatus.BAD_REQUEST);
        } else {
            professeur.setId(id);
            return ResponseEntity.ok(professeurService.update(professeur));
        }
    }

    /*@
      @ requires id >= 0;
      @ ensures \result != null;
      @ ensures (\result.getStatusCode() == HttpStatus.OK) ||
      @         (\result.getStatusCode() == HttpStatus.BAD_REQUEST);
      @*/
    @DeleteMapping("/{id}")
    public ResponseEntity<Object> deleteProfesseur(@PathVariable int id) {
        Professeur professeur = professeurService.findById(id);
        if (professeur == null) {
            return new ResponseEntity<Object>("Professeur with ID " + id + " not found", HttpStatus.BAD_REQUEST);
        } else {
            professeurService.delete(professeur);
            return ResponseEntity.ok("Professeur has been deleted");
        }
    }

    /*@
      @ requires id != null && id >= 0;
      @ ensures \result != null;
      @ ensures (\forall int i; 0 <= i && i < \result.size(); 
      @             \result.get(i).getSpecialite().getId() == id);
      @*/
    @GetMapping("/specialite/{id}")
    public List<Professeur> findProfesseurBySpecialite(@PathVariable Integer id) {
        Specialite specialite = new Specialite();
        specialite.setId(id);
        return professeurService.findBySpecialite(specialite);
    }

    /*@
      @ requires dateDebut != null;
      @ requires dateFin != null;
      @ ensures \result != null;
      @ ensures (\forall int i; 0 <= i && i < \result.size();
      @             dateDebut.compareTo(\result.get(i).getDateEmbauche()) <= 0 &&
      @             \result.get(i).getDateEmbauche().compareTo(dateFin) <= 0);
      @*/
    @GetMapping("/filterByDate")
    public List<Professeur> findByDateEmbaucheBetween(@RequestParam @DateTimeFormat(pattern = "yyyy-MM-dd") Date dateDebut, @RequestParam @DateTimeFormat(pattern = "yyyy-MM-dd") Date dateFin) {
        return professeurService.findByDateEmbaucheBetween(dateDebut, dateFin);
    }
}
