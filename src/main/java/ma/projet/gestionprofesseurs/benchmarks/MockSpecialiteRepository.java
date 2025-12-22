package ma.projet.gestionprofesseurs.benchmarks;

import ma.projet.gestionprofesseurs.entities.Specialite;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * Simple mock repository for JMH benchmarks.
 * This is a minimal implementation for performance testing.
 */
public class MockSpecialiteRepository {
    private final List<Specialite> data = new ArrayList<>();
    
    public Specialite save(Specialite entity) {
        if (entity.getId() == 0) {
            entity.setId(data.size() + 1);
        }
        data.add(entity);
        return entity;
    }
    
    public Optional<Specialite> findById(Integer id) {
        return data.stream().filter(s -> s.getId() == id).findFirst();
    }
    
    public List<Specialite> findAll() {
        return new ArrayList<>(data);
    }
    
    public void delete(Specialite entity) {
        data.remove(entity);
    }
}


