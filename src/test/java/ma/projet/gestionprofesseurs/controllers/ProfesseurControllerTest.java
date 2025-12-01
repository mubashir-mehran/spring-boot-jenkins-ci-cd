package ma.projet.gestionprofesseurs.controllers;

import ma.projet.gestionprofesseurs.entities.Professeur;
import ma.projet.gestionprofesseurs.entities.Specialite;
import ma.projet.gestionprofesseurs.repository.SpecialiteRepository;
import ma.projet.gestionprofesseurs.services.ProfesseurService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ProfesseurControllerTest {

    @Mock
    private ProfesseurService professeurService;

    @Mock
    private SpecialiteRepository specialiteRepository;

    @InjectMocks
    private ProfesseurController professeurController;

    private Professeur professeur;
    private Specialite specialite;

    @BeforeEach
    void setUp() {
        specialite = new Specialite("CS", "Computer Science");
        specialite.setId(1);

        professeur = new Professeur();
        professeur.setId(1);
        professeur.setNom("Doe");
        professeur.setPrenom("John");
        professeur.setEmail("john.doe@example.com");
        professeur.setTelephone("123456789");
        professeur.setDateEmbauche(new Date());
        professeur.setSpecialite(specialite);
    }

    @Test
    void testFindAllProfesseur() {
        List<Professeur> professeurs = new ArrayList<>();
        professeurs.add(professeur);
        when(professeurService.findAll()).thenReturn(professeurs);

        List<Professeur> result = professeurController.findAllProfesseur();

        assertNotNull(result);
        assertEquals(1, result.size());
        verify(professeurService, times(1)).findAll();
    }

    @Test
    void testFindById() {
        when(professeurService.findById(1)).thenReturn(professeur);

        ResponseEntity<Object> response = professeurController.findById(1);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(response.getBody());
        verify(professeurService, times(1)).findById(1);
    }

    @Test
    void testFindByIdNotFound() {
        when(professeurService.findById(999)).thenReturn(null);

        ResponseEntity<Object> response = professeurController.findById(999);

        assertEquals(HttpStatus.BAD_REQUEST, response.getStatusCode());
        assertTrue(response.getBody().toString().contains("not found"));
        verify(professeurService, times(1)).findById(999);
    }

    @Test
    void testCreateProfesseur() {
        when(professeurService.create(any(Professeur.class))).thenReturn(professeur);

        Professeur result = professeurController.createProfesseur(professeur);

        assertNotNull(result);
        assertEquals(0, professeur.getId()); // Should be set to 0
        verify(professeurService, times(1)).create(professeur);
    }

    @Test
    void testUpdateProfesseur() {
        when(professeurService.findById(1)).thenReturn(professeur);
        when(professeurService.update(any(Professeur.class))).thenReturn(professeur);

        ResponseEntity<Object> response = professeurController.updateProfesseur(1, professeur);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertEquals(1, professeur.getId()); // Should be set to the path id
        verify(professeurService, times(1)).findById(1);
        verify(professeurService, times(1)).update(professeur);
    }

    @Test
    void testUpdateProfesseurNotFound() {
        when(professeurService.findById(999)).thenReturn(null);

        ResponseEntity<Object> response = professeurController.updateProfesseur(999, professeur);

        assertEquals(HttpStatus.BAD_REQUEST, response.getStatusCode());
        assertTrue(response.getBody().toString().contains("not found"));
        verify(professeurService, times(1)).findById(999);
        verify(professeurService, never()).update(any());
    }

    @Test
    void testDeleteProfesseur() {
        when(professeurService.findById(1)).thenReturn(professeur);
        doNothing().when(professeurService).delete(professeur);

        ResponseEntity<Object> response = professeurController.deleteProfesseur(1);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertTrue(response.getBody().toString().contains("deleted"));
        verify(professeurService, times(1)).findById(1);
        verify(professeurService, times(1)).delete(professeur);
    }

    @Test
    void testDeleteProfesseurNotFound() {
        when(professeurService.findById(999)).thenReturn(null);

        ResponseEntity<Object> response = professeurController.deleteProfesseur(999);

        assertEquals(HttpStatus.BAD_REQUEST, response.getStatusCode());
        verify(professeurService, times(1)).findById(999);
        verify(professeurService, never()).delete(any());
    }

    @Test
    void testFindProfesseurBySpecialite() {
        List<Professeur> professeurs = new ArrayList<>();
        professeurs.add(professeur);
        when(professeurService.findBySpecialite(any(Specialite.class))).thenReturn(professeurs);

        List<Professeur> result = professeurController.findProfesseurBySpecialite(1);

        assertNotNull(result);
        assertEquals(1, result.size());
        verify(professeurService, times(1)).findBySpecialite(any(Specialite.class));
    }

    @Test
    void testFindByDateEmbaucheBetween() {
        Date dateDebut = new Date();
        Date dateFin = new Date();
        List<Professeur> professeurs = new ArrayList<>();
        professeurs.add(professeur);
        when(professeurService.findByDateEmbaucheBetween(dateDebut, dateFin)).thenReturn(professeurs);

        List<Professeur> result = professeurController.findByDateEmbaucheBetween(dateDebut, dateFin);

        assertNotNull(result);
        assertEquals(1, result.size());
        verify(professeurService, times(1)).findByDateEmbaucheBetween(dateDebut, dateFin);
    }
}

