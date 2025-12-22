package ma.projet.gestionprofesseurs.benchmarks;

import ma.projet.gestionprofesseurs.entities.Professeur;
import ma.projet.gestionprofesseurs.entities.Specialite;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Optional;

/**
 * Simple mock repository for JMH benchmarks.
 * This is a minimal implementation for performance testing.
 */
public class MockProfesseurRepository {
    private final List<Professeur> data = new ArrayList<>();
    
    public Professeur save(Professeur entity) {
        if (entity.getId() == 0) {
            entity.setId(data.size() + 1);
        }
        data.add(entity);
        return entity;
    }
    
    public Optional<Professeur> findById(Integer id) {
        return data.stream().filter(p -> p.getId() == id).findFirst();
    }
    
    public List<Professeur> findAll() {
        return new ArrayList<>(data);
    }
    
    public void delete(Professeur entity) {
        data.remove(entity);
    }
    
    public List<Professeur> findBySpecialite(Specialite specialite) {
        return data.stream()
            .filter(p -> p.getSpecialite() != null && p.getSpecialite().getId() == specialite.getId())
            .toList();
    }
    
    public List<Professeur> findByDateEmbaucheBetween(Date dateDebut, Date dateFin) {
        return data.stream()
            .filter(p -> p.getDateEmbauche() != null && 
                !p.getDateEmbauche().before(dateDebut) && 
                !p.getDateEmbauche().after(dateFin))
            .toList();
    }
}


