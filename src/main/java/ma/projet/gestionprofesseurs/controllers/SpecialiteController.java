package ma.projet.gestionprofesseurs.controllers;

import ma.projet.gestionprofesseurs.entities.Specialite;
import ma.projet.gestionprofesseurs.services.SpecialiteService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/specialite")
public class SpecialiteController {
    @Autowired
    private SpecialiteService specialiteService;

    /*@
      @ ensures \result != null;
      @*/
    @GetMapping
    public List<Specialite> findAllSpecialite() {
        return specialiteService.findAll();
    }

    /*@
      @ requires id >= 0;
      @ ensures \result != null;
      @ ensures (\result.getStatusCode() == HttpStatus.OK && 
      @             \result.getBody() instanceof Specialite) ||
      @         (\result.getStatusCode() == HttpStatus.BAD_REQUEST);
      @*/
    @GetMapping("/{id}")
    public ResponseEntity<Object> findById(@PathVariable int id) {
        Specialite specialite = specialiteService.findById(id);
        if (specialite == null) {
            return new ResponseEntity<Object>("Specialite with ID " + id + " not found", HttpStatus.BAD_REQUEST);
        } else {
            return ResponseEntity.ok(specialite);
        }
    }

    /*@
      @ requires specialite != null;
      @ ensures \result != null;
      @ ensures \result.getId() > 0;
      @*/
    @PostMapping
    public Specialite createSpecialite(@RequestBody Specialite specialite) {
        specialite.setId(0);
        return specialiteService.create(specialite);
    }

    /*@
      @ requires id >= 0;
      @ requires specialite != null;
      @ ensures \result != null;
      @ ensures (\result.getStatusCode() == HttpStatus.OK && 
      @             \result.getBody() instanceof Specialite) ||
      @         (\result.getStatusCode() == HttpStatus.BAD_REQUEST);
      @*/
    @PutMapping("/{id}")
    public ResponseEntity<Object> updateSpecialite(@PathVariable int id, @RequestBody Specialite specialite) {

        if (specialiteService.findById(id) == null) {
            return new ResponseEntity<Object>("Specialite with ID " + id + " not found", HttpStatus.BAD_REQUEST);
        } else {
            specialite.setId(id);
            return ResponseEntity.ok(specialiteService.update(specialite));
        }
    }

    /*@
      @ requires id >= 0;
      @ ensures \result != null;
      @ ensures (\result.getStatusCode() == HttpStatus.OK) ||
      @         (\result.getStatusCode() == HttpStatus.BAD_REQUEST);
      @*/
    @DeleteMapping("/{id}")
    public ResponseEntity<Object> deleteSpecialite(@PathVariable int id) {
        Specialite specialite = specialiteService.findById(id);
        if (specialite == null) {
            return new ResponseEntity<Object>("Specialite with ID " + id + " not found", HttpStatus.BAD_REQUEST);
        } else {
            specialiteService.delete(specialite);
            return ResponseEntity.ok("Specialite has been deleted");
        }
    }
}