package ma.projet.gestionprofesseurs.services;

import ma.projet.gestionprofesseurs.dao.IDao;
import ma.projet.gestionprofesseurs.entities.Specialite;
import ma.projet.gestionprofesseurs.repository.SpecialiteRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class SpecialiteService implements IDao<Specialite> {
    @Autowired
    private SpecialiteRepository specialiteRepository;

    /*@
      @ requires o != null;
      @ ensures \result != null;
      @ ensures \result.getId() == o.getId() || \result.getId() > 0;
      @*/
    @Override
    public Specialite create(Specialite o) {
        return specialiteRepository.save(o);
    }

    /*@
      @ requires o != null;
      @ ensures \result == true || \result == false;
      @*/
    @Override
    public boolean delete(Specialite o) {
        try {
            specialiteRepository.delete(o);
            return true;
        }
        catch(Exception ex) {
            return false;
        }
    }

    /*@
      @ requires o != null;
      @ requires o.getId() > 0;
      @ ensures \result != null;
      @ ensures \result.getId() == o.getId();
      @*/
    @Override
    public Specialite update(Specialite o) {
        return specialiteRepository.save(o);
    }

    /*@
      @ ensures \result != null;
      @*/
    @Override
    public List<Specialite> findAll() {
        return specialiteRepository.findAll();
    }

    /*@
      @ requires id >= 0;
      @ ensures \result == null || \result.getId() == id;
      @*/
    @Override
    public Specialite findById(int id) {
        return specialiteRepository.findById(id).orElse(null);
    }
}