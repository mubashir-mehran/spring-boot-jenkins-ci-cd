package ma.projet.gestionprofesseurs.services;

import ma.projet.gestionprofesseurs.entities.Specialite;
import ma.projet.gestionprofesseurs.repository.SpecialiteRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class SpecialiteServiceTest {

    @Mock
    private SpecialiteRepository specialiteRepository;

    @InjectMocks
    private SpecialiteService specialiteService;

    private Specialite specialite;

    @BeforeEach
    void setUp() {
        specialite = new Specialite("CS", "Computer Science");
        specialite.setId(1);
    }

    @Test
    void testCreate() {
        when(specialiteRepository.save(any(Specialite.class))).thenReturn(specialite);

        Specialite result = specialiteService.create(specialite);

        assertNotNull(result);
        assertEquals(1, result.getId());
        assertEquals("CS", result.getCode());
        assertEquals("Computer Science", result.getLibelle());
        verify(specialiteRepository, times(1)).save(specialite);
    }

    @Test
    void testFindAll() {
        List<Specialite> specialites = new ArrayList<>();
        specialites.add(specialite);
        when(specialiteRepository.findAll()).thenReturn(specialites);

        List<Specialite> result = specialiteService.findAll();

        assertNotNull(result);
        assertEquals(1, result.size());
        assertEquals("CS", result.get(0).getCode());
        verify(specialiteRepository, times(1)).findAll();
    }

    @Test
    void testFindById() {
        when(specialiteRepository.findById(1)).thenReturn(Optional.of(specialite));

        Specialite result = specialiteService.findById(1);

        assertNotNull(result);
        assertEquals(1, result.getId());
        assertEquals("CS", result.getCode());
        verify(specialiteRepository, times(1)).findById(1);
    }

    @Test
    void testFindByIdNotFound() {
        when(specialiteRepository.findById(999)).thenReturn(Optional.empty());

        Specialite result = specialiteService.findById(999);

        assertNull(result);
        verify(specialiteRepository, times(1)).findById(999);
    }

    @Test
    void testUpdate() {
        specialite.setLibelle("Updated Computer Science");
        when(specialiteRepository.save(any(Specialite.class))).thenReturn(specialite);

        Specialite result = specialiteService.update(specialite);

        assertNotNull(result);
        assertEquals("Updated Computer Science", result.getLibelle());
        verify(specialiteRepository, times(1)).save(specialite);
    }

    @Test
    void testDelete() {
        doNothing().when(specialiteRepository).delete(specialite);

        boolean result = specialiteService.delete(specialite);

        assertTrue(result);
        verify(specialiteRepository, times(1)).delete(specialite);
    }

    @Test
    void testDeleteWithException() {
        doThrow(new RuntimeException("Database error")).when(specialiteRepository).delete(specialite);

        boolean result = specialiteService.delete(specialite);

        assertFalse(result);
        verify(specialiteRepository, times(1)).delete(specialite);
    }
}



