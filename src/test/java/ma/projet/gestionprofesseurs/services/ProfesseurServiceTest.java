package ma.projet.gestionprofesseurs.services;

import ma.projet.gestionprofesseurs.entities.Professeur;
import ma.projet.gestionprofesseurs.entities.Specialite;
import ma.projet.gestionprofesseurs.repository.ProfesseurRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ProfesseurServiceTest {

    @Mock
    private ProfesseurRepository professeurRepository;

    @InjectMocks
    private ProfesseurService professeurService;

    private Professeur professeur;
    private Specialite specialite;

    @BeforeEach
    void setUp() {
        specialite = new Specialite("CS", "Computer Science");
        specialite.setId(1);

        professeur = new Professeur();
        professeur.setId(1);
        professeur.setNom("Ali");
        professeur.setPrenom("Raza");
        professeur.setEmail("ali.raza@example.com");
        professeur.setTelephone("123456789");
        professeur.setDateEmbauche(new Date());
        professeur.setSpecialite(specialite);
    }

    @Test
    void testCreate() {
        when(professeurRepository.save(any(Professeur.class))).thenReturn(professeur);

        Professeur result = professeurService.create(professeur);

        assertNotNull(result);
        assertEquals(1, result.getId());
        assertEquals("Ali", result.getNom());
        verify(professeurRepository, times(1)).save(professeur);
    }

    @Test
    void testFindAll() {
        List<Professeur> professeurs = new ArrayList<>();
        professeurs.add(professeur);
        when(professeurRepository.findAll()).thenReturn(professeurs);

        List<Professeur> result = professeurService.findAll();

        assertNotNull(result);
        assertEquals(1, result.size());
        assertEquals("Ali", result.get(0).getNom());
        verify(professeurRepository, times(1)).findAll();
    }

    @Test
    void testFindById() {
        when(professeurRepository.findById(1)).thenReturn(Optional.of(professeur));

        Professeur result = professeurService.findById(1);

        assertNotNull(result);
        assertEquals(1, result.getId());
        assertEquals("Ali", result.getNom());
        verify(professeurRepository, times(1)).findById(1);
    }

    @Test
    void testFindByIdNotFound() {
        when(professeurRepository.findById(999)).thenReturn(Optional.empty());

        Professeur result = professeurService.findById(999);

        assertNull(result);
        verify(professeurRepository, times(1)).findById(999);
    }

    @Test
    void testUpdate() {
        professeur.setNom("Updated");
        when(professeurRepository.save(any(Professeur.class))).thenReturn(professeur);

        Professeur result = professeurService.update(professeur);

        assertNotNull(result);
        assertEquals("Updated", result.getNom());
        verify(professeurRepository, times(1)).save(professeur);
    }

    @Test
    void testDelete() {
        doNothing().when(professeurRepository).delete(professeur);

        boolean result = professeurService.delete(professeur);

        assertTrue(result);
        verify(professeurRepository, times(1)).delete(professeur);
    }

    @Test
    void testDeleteWithException() {
        doThrow(new RuntimeException("Database error")).when(professeurRepository).delete(professeur);

        boolean result = professeurService.delete(professeur);

        assertFalse(result);
        verify(professeurRepository, times(1)).delete(professeur);
    }

    @Test
    void testFindBySpecialite() {
        List<Professeur> professeurs = new ArrayList<>();
        professeurs.add(professeur);
        when(professeurRepository.findBySpecialite(any(Specialite.class))).thenReturn(professeurs);

        List<Professeur> result = professeurService.findBySpecialite(specialite);

        assertNotNull(result);
        assertEquals(1, result.size());
        verify(professeurRepository, times(1)).findBySpecialite(specialite);
    }

    @Test
    void testFindByDateEmbaucheBetween() {
        Date dateDebut = new Date();
        Date dateFin = new Date();
        List<Professeur> professeurs = new ArrayList<>();
        professeurs.add(professeur);
        when(professeurRepository.findByDateEmbaucheBetween(dateDebut, dateFin)).thenReturn(professeurs);

        List<Professeur> result = professeurService.findByDateEmbaucheBetween(dateDebut, dateFin);

        assertNotNull(result);
        assertEquals(1, result.size());
        verify(professeurRepository, times(1)).findByDateEmbaucheBetween(dateDebut, dateFin);
    }
}




